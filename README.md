<h1>AddBuy for YNAB</h1>

Version 0.2

A simple transaction-entry app for YNAB on Sailfish OS.

Privacy Policy: https://www.websitepolicies.com/policies/view/W6aKgySZ

Intended mainly for on-the-spot purchases. For a user who would generally do most of their YNAB budgeting work on a laptop or desktop and mainly use their mobile app for recording transactions (if they're not already synced with bank).

App icon by <a href="https://github.com/JSEHV">JSEHV</a>. Thanks for the contribution!

Requires a YNAB account (paid service, free trial available).

<h3>Rationale</h3>

- Android version of YNAB is incompatible with Alien Dalvik on Sony Xperia X.
- Overall positive to have more native SFOS apps.
- Useful also in learning my way around Qt/QML programming.

<h3>Limitations</h3>

- User will need to reauthorize every two hours. Might look into adding a server-side solution later to avoid this (will need to get acquainted with node.js etc in order to do so). Will not be adding any kind of PAK (personal access key) option, even in advanced/developer settings, as this goes beyond the acceptable use of the API.
- When selecting a default budget and account upon first using the app, user will need to select each from the menu, even if their preferred option is pre-selected, in order to continue.
- When choosing a category for a transaction, as long as the payee already exists (and was assigned a category), leaving the field as Default will assign the last category used with that payee. If entering a new payee, user will need to select a category to avoid leaving this field empty when saving.

<h3>To-do</h3>

- More thorough network error handling.
- Method to notify user if transaction that was just saved puts category balance in the red (aligning more with the purpose of using YNAB).
- May be able to edit New Transaction page so that user doesn't have to restart app if switching to a different budget.

<h3>Support my work</h3>

- <a href="https://buymeacoffee.com/michaeljb">Buy Me A Coffee</a>
- <a href="https://ko-fi.com/michaeljb">Support me on Ko-fi</a>
- <a href="https://paypal.me/michaeljohnbarrett">PayPal.me</a>

Feel free to leave feedback or contact at michael@mjbdev.net
