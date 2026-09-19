# LarpKeeper iOS

A **fake wallet** app for iPhone: a prank/demo tool that looks like a real
crypto wallet but holds invented balances, made-up prices and a simulated
transaction history. Everything is stored on-device and nothing ever touches a
real blockchain, exchange or wallet.

> ⚠️ **This app is a joke.** It contains no real funds and cannot send,
> receive or store anything of value. Do not use it to deceive people.

## Honesty features (by design, not removable)

- On every cold launch a full-screen disclaimer explains the app is fake, with
  a brief hold before "I understand" becomes tappable and a "take me out"
  exit option.
- A red **"DEMO WALLET — ALL DATA IS FAKE"** banner is pinned above every
  screen and cannot be turned off.
- The send flow labels itself "(fake)", simulates progress, then states
  plainly that nothing was sent.
- The receive screen shows a real QR code, but of an invented address, with a
  warning that anyone sending real funds to it loses them.
- Settings contains a permanent "Reality check" section.

## Features

- Wallet screen with total balance, starter fake portfolio (TON / USDT / NOT).
- Add or edit fake assets: emoji icon, name, symbol, chain label, amount,
  price per coin, cosmetic 24h trend.
- Fake send flow with animated "confirmations" that updates balances and logs
  a fake transaction.
- Fake receive screen with a genuine QR code of a fake address.
- Fake transaction history.
- Settings: edit wallet name / fake address, reset demo data.

Requires iOS 16+. No network permission usage, no third-party dependencies.

## Building the IPA (GitHub Actions, no Mac needed)

1. Push to `main` (or run the **Build unsigned IPA** workflow manually from
   the Actions tab).
2. Download the `LarpKeeper-unsigned-ipa` artifact from the finished run.
3. Sign and install with [Sideloadly](https://sideloadly.io),
   [AltStore](https://altstore.io) or similar using your own Apple ID — the
   CI-built IPA is unsigned on purpose.

## Building locally

Open `LarpKeeper.xcodeproj` in Xcode (16+ recommended), pick a team in
Signing & Capabilities and run on a device or simulator.

## Regenerating the icon

```bash
node Scripts/make-icon.js
```

## License

MIT — see [LICENSE](LICENSE).
