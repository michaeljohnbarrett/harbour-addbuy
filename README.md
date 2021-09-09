<h1>AddBuy for YNAB</h1>

Version 0.2

A simple transaction-entry app for YNAB on Sailfish OS.

Privacy Policy: https://www.websitepolicies.com/policies/view/W6aKgySZ

Access key can be removed on the Settings page. Note: If the user selected the 'Keep me logged in' option when initially authorizing the app, they'll need to deauthorize from their YNAB account settings to stop the app from automatically logging back in.

App icon by <a href="https://github.com/JSEHV">JSEHV</a>. Thanks for the contribution!

Requires a YNAB account (paid service, free trial available).

<h3>Rationale</h3>

- Android version of YNAB is incompatible with Alien Dalvik on Sony Xperia X.
- Overall positive to have more native SFOS apps.
- Useful also in learning my way around Qt/QML programming.

<h3>Features</h3>

- Add same-day purchases and inflow transactions to your account(s).
- Check recent transactions
- View read-only budget numbers
- Glance at any two account or budget category balances on the app cover.

<h3>Limitations</h3>

- User will need to reauthorize every two hours. Might look into adding a server-side solution later to avoid this (will need to get acquainted with node.js etc in order to do so). Will not be adding any kind of PAK (personal access key) option, even in advanced/developer settings, as this goes beyond the acceptable use of the API.
- When selecting a default budget and account upon first using the app, user will need to select each from the menu, even if their preferred option is pre-selected, in order to continue.
- When choosing a category for a transaction, as long as the payee already exists (and was assigned a category), leaving the field as Default will assign the last category used with that payee. If entering a new payee, user will need to select a category to avoid leaving this field empty when saving.

<h3>To-do</h3>

- More thorough network error handling.
- Method to notify user if transaction that was just saved puts category balance in the red (aligning more with purpose of using YNAB).
- May be able to edit New Transaction page so that user doesn't have to restart app if switching to a different budget.
- Adjust WebView settings so that 'Forget Access Key' also removes cookies and prevents automatic logging in again of user, and the need to remove the app from YNAB account settings instead. So far issues with adding cookies setting properties to the WebView object have prevented this.

Feel free to leave feedback or contact at addbuy@mjbdev.net
