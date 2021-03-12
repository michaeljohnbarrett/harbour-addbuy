# harbour-addbuy
AddBuy for YNAB

A simple transaction-entry app for YNAB accounts that runs on Sailfish OS.

Privacy Policy: https://www.websitepolicies.com/policies/view/W6aKgySZ

Intended mainly for on-the-spot purchases. For users who generally do most of the budgeting work in YNAB on a laptop or desktop and mainly use their mobile app for recording transactions (if they're not already synced with bank).

When choosing category, as long as the payee already exists (and was assigned a category), leaving the field as Default will assign the last category used with that payee. If entering a new payee, user will need to select a category to avoid this field being empty when saving.

Still in early development. (Incomplete) to-do list:

- More thorough network error handling.
- Add cover page feature, possibly working or cleared balance, or remaning balance in a given category.
- Add page on which user can setup OAuth and add accompanying OAuth code. Will need Sailfish Secrets implementation for access keys, whether it's OAuth or a possible option for user to use their own PAK to avoid timing out. Will include disclaimer if PAK option is available (i.e. this isn't me asking for your PAK!)
- Under the hood, will probably migrate existing XHttpRequest code (all connections other than saving transaction POST) to the C++ class for consistency and performance. C++ class was created due to blank page issue with POST request using XHttpRequest method.
- Cleanup and/or tighten code when formatting main figure box on New Transaction page and in other areas.
- May be able to edit New Transaction page so that user doesn't have to restart app if switching to a different budget.
- Improve icon.

Further down the road:

- Method to notify user if transaction just saved puts category balance in the red (kind of essential to be associated with the YNAB service).
- Possible option to select and edit recent transactions (only in landscape as the type would be too small in portrait) and budget amounts.
- Possible option to enter income transactions, although not the primary intended use of the app and would add some clutter to New Transaction page.
