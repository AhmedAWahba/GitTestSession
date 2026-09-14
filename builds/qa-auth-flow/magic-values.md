# Magic values

The Apex QA app is not connected to a server yet. A fake server lives inside the app.
What you type decides what happens next. This page lists the values that matter.
Any value not listed here takes the normal, happy path.

Install: **Apex QA** (`com.qawafel.apex.testing`).

Two things to know before you start:

- Sign up progress is kept in memory only. If you kill the app during sign up, you start
  again from the first screen.
- After you sign in, the session is saved. Killing the app keeps you signed in.

---

## Fast path: sign up from start to finish

1. Email `buyer@example.com`, password `Qawafel1234-`, same password again.
2. Email code `123456`.
3. Mobile number `512345670`, then code `123456`.
4. National ID `1000000000`, any date of birth in the past.
5. Wait about four seconds. The Nafath step completes by itself.
6. Business number `7001234567`, VAT number `300123456700003`, leave TIN empty.
   Wait about two seconds, then tap Confirm.
7. Any bank, IBAN `0380000000608010167519`. Or tap **Add later** to skip.

---

## Sign in

The password is checked first, then the email.

| Type this | What happens |
|---|---|
| password `wrong`, any email | "Incorrect email or password" |
| `unverified@qawafel.com` | Goes to the email code screen |
| `step-user@` any domain | Code, then the mobile number screen |
| `step-mobile@` any domain | Code, then the mobile number screen |
| `step-kyc@` any domain | Code, then the identity details screen |
| `step-business@` any domain | Code, then the business details screen |
| `step-bank@` any domain | Code, then the bank details screen |
| `revoked@qawafel.com` | Signs in. Next app launch throws you out to sign in |
| `offline@qawafel.com` | Signs in. Next app launch shows the retry screen |
| any other email | Signs in with one business |

Every sign in asks for a code. Use the codes below.

To see the retry screen on launch another way: turn airplane mode on, then open the app.

---

## Codes

Same codes for the sign in code, the email code and the mobile code.

| Type this | What happens |
|---|---|
| `123456` | Accepted |
| `000000` | The code is burned and a cooldown starts |
| anything else | Counts as a wrong try. Five wrong tries and the code is burned |

---

## Sign up: account

| Field | Type this | What happens |
|---|---|---|
| Email | `taken@qawafel.com` | "Email already in use" on the field |
| Email | any other valid email | Account created |

---

## Sign up: identity

**Mobile number.** Type the nine digits only. The `+966` is already there.

| Type this | What happens |
|---|---|
| `512345678` | "Already registered" on the field |
| any other nine digits | Code sent |

**National ID.** Ten digits. National ID starts with `1`. Iqama starts with `2`.
This value decides how the Nafath step ends.

| Type this | What happens |
|---|---|
| `1000000000` | Completes |
| `1000000001` | Rejected in the Nafath app |
| `1000000002` | Expired by Nafath |
| `1000000003` | Failed, identity mismatch. No retry offered |
| `1000000004` | Never finishes. Wait for the 00:00 timer to see the timeout panel |
| `2000000000` | Nafath cannot start at all |
| any other valid number | Completes |

---

## Sign up: business

**Unified National Number.** Ten digits, starts with `7`.

| Type this | What happens |
|---|---|
| `7000000001` | Not found |
| `7000000002` | You are not the legal owner |
| `7000000003` | Already registered on Qawafel |
| `7000000004` | The registry cannot be reached |
| `7000000005` | Found, but Confirm then fails with "VAT number already used" |
| any other valid number | Found. Tap Confirm to continue |

A found business always shows as `شركة السجل التجاري المحلية`, CR number `1010711252`.

**VAT number.** Fifteen digits, starts and ends with `3`. No special values.
**TIN.** Optional. Ten digits if given.

**Lookup limit.** This one is real. Five lookups per hour. The sixth shows a warning
with a countdown.

---

## Sign up: bank

**IBAN.** Type the twenty two characters after `SA`. The `SA` is already there.

| Type this | What happens |
|---|---|
| `6120000000123456789012` | "Already registered" on the field |
| `0380000000608010167519` | Saved |
| any other real IBAN | Saved |

A made up IBAN is refused before it is sent. Use one of the two above.

**Add later** skips the bank step and finishes sign up.

---

## Timers

| What | How long |
|---|---|
| A code stays valid | 3 minutes |
| Resend allowed after | 60 seconds |
| Resends per code | 3 |
| Wrong tries per code | 5 |
| Cooldown after a burned code | 10 minutes, doubles each time |
| Nafath step completes after | about 4 seconds |
| Nafath step times out after | 3 minutes |
| Business lookup answers after | about 2 seconds |
| Business lookups per hour | 5 |
| Sign in answers after | about 1 second |

---

## For developers

This page is the only list. Keep it in step with `StubAuthRepository` and
`StubRegistrationRepository`, and delete all three together in the change that introduces
the first real Ktor data source.

The timers are copied from the backend, not chosen, so the UI meets the real numbers:

| Timer | Source |
|---|---|
| Code lifetime, resend delay, wrong tries, cooldown, lookup limit and window | `Apex.Account.Verification` `@defaults` |
| Nafath step lifetime | `Gateway.Nafath.Adapters.Local.StorageManager`, 180s |
| Business name and CR number for a found business | the backend local Wathq adapter |
| Sign in resend rules | product PRD FR-SI.4 |
| Nafath settle delay, lookup latency, sign in latency | invented, long enough to see the loading states |

The IBAN check is the same mod 97-10 checksum as `Apex.Utils.Iban.verify/1`. The saved
example IBAN is that module's own example.
