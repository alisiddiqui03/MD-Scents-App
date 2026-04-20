# MD Scents App

Flutter eCommerce app using GetX + Firebase Firestore.

## Core Features

- Auth + user profile (`AuthService`)
- Product catalog + inventory (`ProductService`)
- Cart + checkout + order placement (`CartController`)
- Wallet + referral rewards (`WalletService`, `ReferralService`)
- Points + points history (`PointsService`)
- 90-day milestone rewards (`MilestoneService`)
- VIP membership + high-roller bonus (`VipService`)
- Admin panels (orders, inventory, ads/discount, VIP request verification)

## Firestore Collections (Relevant)

- `users/{uid}`
- `users/{uid}/orders/{orderId}`
- `users/{uid}/points_history/{id}`
- `users/{uid}/referrals/{id}`
- `products/{productId}`
- `referralCodes/{code}`
- `vipRequests/{uid}` (latest VIP payment request per user)

## Rewards & VIP Architecture

### Orchestration

Order placement transaction stays in `CartController.placeOrder()`, but reward logic is modular:

- `OrderService.applyPostOrderRewardsInTransaction(...)` (orchestrator)
  - `PointsService.handleOrderPoints(...)`
  - `MilestoneService.handleMilestone(...)`
  - `VipService.handleVipBenefits(...)`

All these run in the **same Firestore transaction**.

### Points Rules

- Normal user: `1 point / 200 PKR`
- VIP active user: `2 points / 200 PKR`
- Points are always logged in `users/{uid}/points_history`.

### 90-Day Milestone Rules

- Milestone cycle starts from first qualifying order.
- Cycle duration: 90 days.
- Qualifying order: `order.total >= 10,000 PKR`
- Cooldown: max 1 qualifying count every 24 hours.
- Rewards:
  - 1st qualifying order: +50 points
  - 5th qualifying order: +100 points
  - 10th qualifying order: +1000 points
- Tracked in user doc:
  - `milestoneStartDate`
  - `milestoneOrderCount`
  - `lastMilestoneOrderTime`

### VIP Membership Rules

Tracked fields in `users/{uid}`:

- `isVip`
- `vipType` (`monthly` or `yearly`)
- `vipStartDate`
- `vipEndDate`
- `vipHighRollerSpent`
- `vipHighRollerRewardGiven`

VIP active check is expiry-aware using `AppUser.isVipActive`.

#### High Roller (Yearly VIP only)

- Threshold spend: `1,000,000 PKR`
- One-time bonus: `+10,000 points`
- Duplicate reward prevented by `vipHighRollerRewardGiven`.

## VIP Purchase & Activation Flow

### User Side

Screen: `MD VIP Club` (`/user/vip-dashboard`)

1. Select VIP plan:
   - Monthly: `PKR 1,500 / month`
   - Yearly: `PKR 15,000 / year` (save `PKR 3,000`)
2. Upload payment screenshot.
3. Submit VIP request.

This creates/updates `vipRequests/{uid}` with `status: pending`.

### Admin Side

Screen: `Admin > Ads & user discounts` (existing admin module, no new module)

1. Review pending VIP requests.
2. Open payment screenshot.
3. Tap **Approve & Activate**.

On approval:

- user VIP fields are activated/reset through `VipService.activateVipForUser(...)`
- request status updated to `approved` with review metadata.

## UI Placement

- 90-day milestone tracker is reusable (`MilestoneTrackerWidget`) and placed in:
  - Discounts screen
  - Profile screen
  - VIP dashboard
- Profile shows VIP gold badge + expiry if VIP active.
- Product `isVipOnly` is respected for non-VIP users.

## Development Notes

- Business logic lives in services, not controllers.
- Existing checkout/wallet/referral flows are extended safely (not replaced).
- Use Firestore transactions for reward integrity.

