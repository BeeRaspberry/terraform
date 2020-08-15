# Google Cloud Instructions

This code leverages Google's Identity-Aware Proxy (IAP) needs to be configured prior to attempting to access the cluster.

Configuring consists of establishing a 'consent screen'

## Configuring IAP

*   [Consent Screen](https://console.cloud.google.com/security/iap)
*   Select a User Type (Internal or External). Unless the account belongs to an organization you'll need to select 'Externa'. Google is kind enough to disable 'internal' when your account doesn't belong to an organization.
*   The next screen is more personal, you'll need to complete based on your needs. Save when done.
