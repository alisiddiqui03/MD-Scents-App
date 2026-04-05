# Refer & Earn — Poora Flow (MD Scents App)

Yeh document **Roman Urdu + English** mein explain karta hai ke referral system app mein kaise connected hai, admin ko kya dikhta hai, aur “first order” ka pata kaise lagta hai. **Cloud Functions ki zaroorat nahi** — sab Firestore + Flutter client par hai.

---

## 1. Short summary (jawab seedha)

| Sawal | Jawab |
|--------|--------|
| **Admin ko kaise pata chalega ke user referral se aaya hai?** | Order detail mein **`referredBy`** (referrer ka Firebase **User ID**) + **“Free delivery (referral)”** jab applicable ho. User profile par bhi **`referredBy`** save hota hai. |
| **First order kaise detect hota hai?** | App **`users/{uid}/orders`** ki **count** dekhti hai: **`completedOrderCount == 0`** matlab abhi tak koi order place nahi hua → **first order** for referral. Order document par **`isFirstOrderForUser: true`** bhi likha jata hai. |
| **Referrer ko PKR 500 kab milta hai?** | Jab admin order status **Delivered** kare, aur order pe **`referralRewardPending`** true ho → **referrer** ke **`users/{referrerUid}.wallet.balance`** mein **+500** (ek dafa, idempotent). |

---

## 2. Components (sab connected kahan se)

| Piece | File / location | Kaam |
|--------|------------------|------|
| Referral code generate | `ReferralService` + `main.dart` mein register | Login ke baad **`ensureReferralCodeIfNeeded`** → **`referralCodes/{code}`** + **`users.referralCode`** |
| User apna code share | `ReferEarnController` | `AuthService` se code, `share_plus` se share text |
| Checkout par code | `CartController` | Text field → **`validateForFirstOrder`** → transaction |
| Order + wallet | `CartController` + `Order` model | Firestore writes |
| Referrer reward | `OrderService._grantReferrerRewardIfEligible` | **Delivered** par wallet + referral doc **completed** |
| Admin orders UI | `orders_view.dart` | Order sheet: referral section + free delivery chip |
| Admin dashboard | `admin_dashboard_view.dart` → `_ReferralsAdminCard` | **`AdminReferralsService`** → collection group **`referrals`** |
| Admin referrals data | `AdminReferralsService` | `collectionGroup('referrals')` |

**`main.dart`** mein **`ReferralService`** aur **`AdminReferralsService`** dono `Get.put` se load ho rahe hain — yeh flow activate rehta hai.

---

## 3. User flow (step-by-step)

### A) Referrer (jis ne code share kiya)

1. User login karta hai → **`ReferralService`** auto **`ensureReferralCodeIfNeeded`** chalata hai.
2. Unique **8 character** code **`referralCodes/{CODE}`** mein map hota hai **`uid`** ke sath, aur **`users/{uid}.referralCode`** set hota hai.
3. **Refer & Earn** screen se **`ReferEarnController`** code dikhata / **Share** karta hai.

### B) Naya user (jis ne code cart mein daala)

1. **Pehla order** tabhi referral reward rules apply honge jab:
   - **`completedOrderCount == 0`** (purane orders ki count Firestore se).
   - Pehle se **`users/{uid}.referredBy`** empty ho (ek dafa link ho gaya to dubara code use nahi).
2. Cart mein code enter → **`validateForFirstOrder`**:
   - Code **`referralCodes`** se resolve → referrer ka **uid**.
   - Khud ka code use nahi, referrer buyer na ho.
3. **Place order** ek **transaction** mein:
   - Stock kam,
   - Optional **wallet** debit,
   - **`users/{buyer}.referredBy`** = referrer uid (agar valid),
   - **`users/{referrer}/referrals/{newDocId}`** = pending record (referred user, order id, reward amount),
   - **`users/{buyer}/orders/{orderId}`** = saari referral fields + **`referralFreeDelivery`**, **`isFirstOrderForUser`**, etc.
4. Success ke baad **`refreshProfile()`** taake buyer ke profile mein **`referredBy`** UI par aa jaye.

### C) “Free delivery”

- App prices **delivery fee alag line item** ke bina calculate karti hai; referral **flag** (**`referralFreeDelivery`**) **UI / admin** ke liye hai ke yeh order referral perk ke sath hai.
- Cart summary mein preview/debounced validation se user ko message milta hai jab code valid ho.

---

## 4. Admin ko kya dikhta hai?

### A) Order detail (Admin → Orders → kisi order par tap)

- **“Free delivery (referral)”** — agar order par **`referralFreeDelivery`** true ho.
- **Referral** section agar **`referredBy`** set ho:
  - **Referrer user ID:** woh Firebase UID jis ne refer kiya.
  - **Reward status:** `Order.referralStatusLabel`:
    - **Pending (deliver order)** — abhi deliver nahi hua ya reward pending.
    - **Reward paid** — deliver ke baad referrer ko credit ho chuka.

### B) Admin dashboard

- **“Referrals”** card: **`AdminReferralsService`** se recent rows — **referrer → invited user**, **Pending / Completed** status.
- Card text ke mutabiq: pending tab tak clear hota hai jab order **Delivered** ho jaye aur reward flow run ho (UI copy mein “Paid” bhi mention ho sakta hai — actual logic code **`OrderService`** mein status **delivered** + flags par hai).

### C) Pehla order — admin ko kis field se pata?

- Order document par **`isFirstOrderForUser: true`** explicitly save hota hai **first-ever** order ke waqt (jab count 0 thi).
- Agar user pehle bina referral ke order kar chuka ho, phir referral use karne ki koshish kare → validation fail / reward nahi — **first order** condition sirf **count == 0** par.

---

## 5. Firestore structure (referral se related)

```
referralCodes/{CODE}
  uid: string          → referrer ka Firebase Auth UID
  createdAt: timestamp

users/{uid}
  referralCode: string    → apna share code
  referredBy: string      → jis referrer ne link kiya (buyer par, ek dafa)
  wallet:
    balance: number
    pendingRewards: number

users/{referrerUid}/referrals/{referralDocId}
  referredUserId, referrerUid, orderId
  status: "pending" | "completed"
  rewardAmount: number (e.g. 500)
  createdAt, completedAt (jab complete ho)

users/{buyerUid}/orders/{orderId}
  userId, items, total, status, ...
  referredBy, referralUsed, referralApplied
  isFirstOrderForUser, referralRewardPending, referralRewardGranted
  referralRecordId  → referrer ke referrals subdoc se link
  referralFreeDelivery, referralCodeEntered, ...
```

---

## 6. Referrer PKR 500 — exact trigger

1. Admin **`OrderService.updateStatus`** se order **`delivered`** karta hai.
2. **`_grantReferrerRewardIfEligible`** sirf tab chalta hai jab **`AuthService.isAdmin`** true ho (app mein **`users/{uid}.role == 'admin'`**).
3. Transaction:
   - Order pe **`referralRewardPending`** true aur **`referralRewardGranted`** false ho,
   - **`referredBy`** se referrer uid,
   - **`users/{referrer}.wallet.balance`** += **500** (`kReferralRewardPkr`),
   - Order par **`referralRewardGranted: true`**, **`referralRewardPending: false`**,
   - **`users/{referrer}/referrals/{referralRecordId}`** → **`status: completed`**.

Agar pehle hi **`referralRewardGranted`** true ho → dubara credit nahi (duplicate protection).

---

## 7. Verification checklist (sab sahi chal raha hai?)

| Check | Expected |
|--------|----------|
| `main.dart` | `ReferralService` + `AdminReferralsService` registered |
| Naya user register | `users/{uid}` + `wallet` initial |
| Login | Referral code auto-generate ho (agar pehle na ho) |
| First order + valid code | Transaction mein `referredBy`, order fields, `referrals` subdoc |
| Second order + same code | Validation fail / reward nahi (first order + already linked rules) |
| Admin order sheet | `referredBy` + reward status dikhe jab referral order ho |
| Admin Delivered | Referrer wallet +500, referral row completed |
| Refer & Earn screen | `referralsStream` se list (referrer apni referrals dekhe) |

---

## 8. Important notes (production)

1. **Firestore rules:** Repo ke `firestore.rules` mein **`referralCodes`**, **`users/.../referrals`**, **wallet** updates, aur **collection group `referrals`** ke liye jo rules tum deploy karte ho, woh in client writes ke mutabiq hon — warna permission errors aa sakte hain. Rules file hamesha **Firebase Console** ke deployed version se match verify karo.

2. **Admin role:** App **`AppUser.role == 'admin'`** se admin samajhti hai; Firestore rules mein agar **`request.auth.token.admin`** use ho to Firebase Console mein **custom claims** + Firestore **`role`** dono align karne pad sakte hain.

3. **Indexes:** `collectionGroup('referrals').orderBy('createdAt')` aur `collectionGroup('orders').orderBy('createdAt')` ke liye Firestore **composite index** maang sakta hai — Console link error se add karo.

---

## 9. Quick flow diagram

```
[Signup/Login] → users/{uid}
       ↓
[ReferralService] → referralCodes/{CODE} + users.referralCode
       ↓
[Cart: first order + code] → validateForFirstOrder
       ↓
[Transaction] → stock, wallet?, referral doc, order doc, users.referredBy
       ↓
[Admin: Orders] → referredBy + reward status + free delivery flag
       ↓
[Admin: Delivered] → referrer wallet +500, referrals completed
```

---

*Yeh document sirf existing implementation describe karta hai; architecture change nahi.*
