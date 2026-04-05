"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onUserOrderUpdated = exports.onUserOrderCreated = exports.ensureReferralCode = void 0;
/**
 * MD Scents — server-side referral & wallet logic.
 * Reward amounts and eligibility MUST match product expectations; clients only hint values.
 */
const logger = __importStar(require("firebase-functions/logger"));
const admin = __importStar(require("firebase-admin"));
const firestore_1 = require("firebase-functions/v2/firestore");
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
admin.initializeApp();
(0, v2_1.setGlobalOptions)({ region: "us-central1", maxInstances: 20 });
const db = admin.firestore();
const REFERRAL_REWARD_PKR = 500;
function readWallet(data) {
    const w = data?.wallet ?? {};
    return {
        balance: Number(w.balance ?? 0) || 0,
        pendingRewards: Number(w.pendingRewards ?? 0) || 0,
    };
}
function normalizePhone(raw) {
    if (!raw)
        return null;
    let s = raw.trim().replace(/\s+/g, "");
    if (s.startsWith("00"))
        s = s.slice(2);
    if (s.startsWith("+"))
        s = s.slice(1);
    s = s.replace(/[^\d]/g, "");
    if (s.length < 10)
        return null;
    if (s.startsWith("0") && s.length >= 11)
        s = s.slice(1);
    if (!s.startsWith("92") && s.length === 10) {
        s = "92" + s;
    }
    return s;
}
function randomCode(len = 8) {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let out = "";
    for (let i = 0; i < len; i++) {
        out += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return out;
}
/** Callable: idempotently assign a globally unique referral code to the signed-in user. */
exports.ensureReferralCode = (0, https_1.onCall)(async (request) => {
    if (!request.auth?.uid) {
        throw new https_1.HttpsError("unauthenticated", "Sign in required.");
    }
    const uid = request.auth.uid;
    const userRef = db.collection("users").doc(uid);
    const existing = await userRef.get();
    const codeExisting = existing.get("referralCode");
    if (typeof codeExisting === "string" && codeExisting.length > 0) {
        return { referralCode: codeExisting };
    }
    for (let attempt = 0; attempt < 40; attempt++) {
        const code = randomCode(8);
        const codeRef = db.collection("referralCodes").doc(code);
        try {
            await db.runTransaction(async (tx) => {
                const cSnap = await tx.get(codeRef);
                if (cSnap.exists) {
                    throw new Error("collision");
                }
                const uSnap = await tx.get(userRef);
                const ex2 = uSnap.get("referralCode");
                if (typeof ex2 === "string" && ex2.length > 0) {
                    throw new Error("already");
                }
                tx.set(codeRef, { uid, createdAt: admin.firestore.FieldValue.serverTimestamp() });
                const w0 = readWallet(uSnap.data());
                tx.set(userRef, {
                    referralCode: code,
                    wallet: {
                        balance: w0.balance,
                        pendingRewards: w0.pendingRewards,
                    },
                }, { merge: true });
            });
            return { referralCode: code };
        }
        catch (e) {
            const msg = e.message;
            if (msg === "collision")
                continue;
            if (msg === "already") {
                const u = await userRef.get();
                const c = u.get("referralCode");
                if (c)
                    return { referralCode: c };
                continue;
            }
            throw e;
        }
    }
    throw new https_1.HttpsError("internal", "Could not allocate referral code.");
});
async function restockItems(items) {
    const batch = db.batch();
    let n = 0;
    for (const line of items) {
        const pid = line.productId;
        const qty = line.quantity ?? 0;
        if (!pid || qty <= 0)
            continue;
        const pref = db.collection("products").doc(pid);
        batch.update(pref, { stock: admin.firestore.FieldValue.increment(qty) });
        n++;
    }
    if (n > 0)
        await batch.commit();
}
async function cancelOrderForWalletFailure(userId, orderId, items) {
    const orderRef = db.collection("users").doc(userId).collection("orders").doc(orderId);
    await restockItems(items);
    await orderRef.update({
        status: "cancelled",
        cancellationReason: "Wallet verification failed — order reversed. Please try again.",
        cancelledAt: admin.firestore.FieldValue.serverTimestamp(),
        cancellationUnreadForUser: true,
        referralServerProcessed: true,
        walletDebitReversed: true,
    });
}
/**
 * After order create: verify wallet debit; on first valid referral, create pending reward.
 */
exports.onUserOrderCreated = (0, firestore_1.onDocumentCreated)("users/{userId}/orders/{orderId}", async (event) => {
    const userId = event.params.userId;
    const orderId = event.params.orderId;
    const snap = event.data;
    if (!snap)
        return;
    const data = snap.data();
    if (data.referralServerProcessed === true) {
        return;
    }
    const items = data.items ?? [];
    const walletApplied = Math.max(0, Number(data.walletAppliedAmount ?? 0) || 0);
    const orderRef = db.collection("users").doc(userId).collection("orders").doc(orderId);
    const userRef = db.collection("users").doc(userId);
    // ── Wallet: server is source of truth; cancel + restock if invalid ─────────
    if (walletApplied > 0.009) {
        try {
            await db.runTransaction(async (tx) => {
                const u = await tx.get(userRef);
                const w = readWallet(u.data());
                if (w.balance + 1e-6 < walletApplied) {
                    throw new Error("insufficient_wallet");
                }
                const nextBal = Math.max(0, w.balance - walletApplied);
                tx.set(userRef, {
                    wallet: {
                        balance: nextBal,
                        pendingRewards: w.pendingRewards,
                    },
                }, { merge: true });
                tx.set(orderRef, {
                    walletDebitConfirmed: true,
                }, { merge: true });
            });
        }
        catch (e) {
            if (e.message === "insufficient_wallet") {
                logger.warn("Wallet debit failed; cancelling order", { userId, orderId });
                await cancelOrderForWalletFailure(userId, orderId, items);
                return;
            }
            logger.error("Wallet transaction error", e);
            throw e;
        }
    }
    // ── First order? ──────────────────────────────────────────────────────────
    const siblings = await db
        .collection("users")
        .doc(userId)
        .collection("orders")
        .limit(2)
        .get();
    const isFirstOrder = siblings.size <= 1;
    if (!isFirstOrder) {
        await orderRef.set({ referralServerProcessed: true }, { merge: true });
        return;
    }
    const rawCode = data.referralCodeEntered?.trim().toUpperCase();
    const deviceId = data.referralDeviceId?.trim() ?? "";
    // No minimum order value — valid code on first order only (validated below).
    if (!rawCode) {
        await orderRef.set({ referralServerProcessed: true }, { merge: true });
        return;
    }
    const phone = normalizePhone(data.deliveryPhone);
    if (!phone) {
        await orderRef.set({ referralServerProcessed: true }, { merge: true });
        return;
    }
    try {
        await db.runTransaction(async (tx) => {
            const orderSnap = await tx.get(orderRef);
            const od = orderSnap.data() ?? {};
            if (od.referralServerProcessed === true)
                return;
            const codeRef = db.collection("referralCodes").doc(rawCode);
            const codeSnap = await tx.get(codeRef);
            if (!codeSnap.exists) {
                tx.set(orderRef, { referralServerProcessed: true, referralRejected: "invalid_code" }, { merge: true });
                return;
            }
            const referrerUid = codeSnap.get("uid");
            if (!referrerUid || referrerUid === userId) {
                tx.set(orderRef, { referralServerProcessed: true, referralRejected: "self_or_bad" }, { merge: true });
                return;
            }
            const userSnap = await tx.get(userRef);
            const referredByExisting = userSnap.get("referredBy");
            if (referredByExisting && referredByExisting.length > 0) {
                tx.set(orderRef, { referralServerProcessed: true, referralRejected: "already_linked" }, { merge: true });
                return;
            }
            const phoneKey = `referralPhoneLocks/${phone}`;
            const devKey = deviceId.length > 8 ? `referralDeviceLocks/${deviceId}` : null;
            const phoneRef = db.doc(phoneKey);
            const phoneSnap = await tx.get(phoneRef);
            if (phoneSnap.exists) {
                const owner = phoneSnap.get("uid");
                if (owner && owner !== userId) {
                    tx.set(orderRef, { referralServerProcessed: true, referralRejected: "phone_in_use" }, { merge: true });
                    return;
                }
            }
            if (devKey) {
                const devRef = db.doc(devKey);
                const devSnap = await tx.get(devRef);
                if (devSnap.exists) {
                    const owner = devSnap.get("uid");
                    if (owner && owner !== userId) {
                        tx.set(orderRef, { referralServerProcessed: true, referralRejected: "device_in_use" }, { merge: true });
                        return;
                    }
                }
            }
            /** One referral reward per referred user, ever (guards races / duplicates). */
            const globalRewardRef = db.collection("referralRewardsByUser").doc(userId);
            const globalSnap = await tx.get(globalRewardRef);
            if (globalSnap.exists) {
                tx.set(orderRef, {
                    referralServerProcessed: true,
                    referralRejected: "referral_reward_already_issued",
                }, { merge: true });
                return;
            }
            const referrerRef = db.collection("users").doc(referrerUid);
            const referrerSnap = await tx.get(referrerRef);
            const rw = readWallet(referrerSnap.data());
            const pending = rw.pendingRewards;
            const referralCol = referrerRef.collection("referrals");
            const newRef = referralCol.doc();
            tx.set(userRef, { referredBy: referrerUid }, { merge: true });
            tx.set(phoneRef, { uid: userId, createdAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
            if (devKey) {
                tx.set(db.doc(devKey), { uid: userId, createdAt: admin.firestore.FieldValue.serverTimestamp() }, { merge: true });
            }
            tx.set(newRef, {
                referredUserId: userId,
                orderId,
                status: "pending",
                rewardAmount: REFERRAL_REWARD_PKR,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                normalizedPhone: phone,
                deviceId: deviceId || null,
            });
            tx.set(referrerRef, {
                wallet: {
                    balance: rw.balance,
                    pendingRewards: pending + REFERRAL_REWARD_PKR,
                },
            }, { merge: true });
            tx.set(globalRewardRef, {
                referrerUid,
                orderId,
                referralDocId: newRef.id,
                status: "pending",
                rewardAmount: REFERRAL_REWARD_PKR,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            tx.set(orderRef, {
                referralServerProcessed: true,
                referralRewardReferrerUid: referrerUid,
                referralRewardDocId: newRef.id,
                referralRewardActivated: false,
                /** Referred customer: free delivery on this order (PKR amount is operational; flag is source of truth). */
                referralFreeDelivery: true,
            }, { merge: true });
        });
    }
    catch (e) {
        logger.error("Referral transaction failed", e);
        await orderRef.set({ referralServerProcessed: true, referralRejected: "server_error" }, { merge: true });
    }
});
/** When admin marks Delivered + Paid, move pending referral reward to active wallet balance. */
exports.onUserOrderUpdated = (0, firestore_1.onDocumentUpdated)("users/{userId}/orders/{orderId}", async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after)
        return;
    const userId = event.params.userId;
    const orderId = event.params.orderId;
    const deliveredPaid = after.status === "delivered" &&
        after.isPaid === true &&
        (before.status !== "delivered" || before.isPaid !== true);
    if (!deliveredPaid)
        return;
    if (after.referralRewardActivated === true)
        return;
    const referrerUid = after.referralRewardReferrerUid;
    const referralDocId = after.referralRewardDocId;
    if (!referrerUid || !referralDocId)
        return;
    const orderRef = db.collection("users").doc(userId).collection("orders").doc(orderId);
    const referralRef = db
        .collection("users")
        .doc(referrerUid)
        .collection("referrals")
        .doc(referralDocId);
    const referrerRef = db.collection("users").doc(referrerUid);
    const globalRewardRef = db.collection("referralRewardsByUser").doc(userId);
    try {
        await db.runTransaction(async (tx) => {
            const refSnap = await tx.get(referralRef);
            if (!refSnap.exists)
                return;
            const st = refSnap.get("status");
            if (st !== "pending")
                return;
            const rSnap = await tx.get(referrerRef);
            const rw = readWallet(rSnap.data());
            const balance = rw.balance;
            const pending = rw.pendingRewards;
            const reward = Number(refSnap.get("rewardAmount") ?? REFERRAL_REWARD_PKR) || REFERRAL_REWARD_PKR;
            if (pending + 1e-6 < reward) {
                logger.error("Pending rewards mismatch", { referrerUid, pending, reward });
                return;
            }
            tx.update(referralRef, {
                status: "completed",
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            tx.set(referrerRef, {
                wallet: {
                    balance: balance + reward,
                    pendingRewards: Math.max(0, pending - reward),
                },
            }, { merge: true });
            tx.set(orderRef, { referralRewardActivated: true }, { merge: true });
            tx.set(globalRewardRef, {
                status: "completed",
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
            }, { merge: true });
        });
    }
    catch (e) {
        logger.error("Referral activation failed", e);
    }
});
//# sourceMappingURL=index.js.map