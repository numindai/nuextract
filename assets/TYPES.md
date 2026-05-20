| Type | Description | Examples |
| --- | --- | --- |
| **integer** | An integer number. | 12, 0, -4 |
| **number** | Any number, including floating point or integers. | 3.14, -9.1, 0 |
| **string** | A general string; can be abstractive or deduced from reasoning. | Hello World, any string |
| **verbatim-string** | Strictly extractive from input; preserves all characters (accents, emojis) but normalizes whitespace/tabs to a single space. | John Doe, 1120 Santa Monica Boulevard |
| **date** | ISO 8601 compliant. Supports reduced accuracy (YYYY-MM, YYYY, --MM-DD) and week dates (YYYY-Www). | 2024-01-15, 2024-01, --12-25 |
| **time** | ISO 8601 compliant. Supports reduced accuracy and timezone offsets (+hh-mm). | 14:30:57, 18:01, 14:30:45.123Z |
| **date-time** | ISO 8601 compliant (YYYY-MM-DDThh:mm:ss.s+hh-mm). Can omit components if only date or time is present. | 2024-03-14T14:45:00, 2023-05-15T14 |
| **duration** | ISO 8601 duration (PnYnMnDTnHnMnS). "P3W" (weeks) cannot be combined with other date components. | P2Y1M3D, PT1M30S, P3W |
| **boolean** | A logic value of true or false. | true, false |
| **country** | Uppercase 2-character ISO 3166-1 country code. | FR, SG, KR |
| **currency** | Uppercase 3-character ISO 4217 code. Covers current and historic currencies. | EUR, USD, DEM |
| **language** | Lowercase 3-character ISO 639-3 language code. | eng, fra, cos |
| **language-tag** | IETF BCP 47 / RFC 5646 tag. Includes language, script (opt), region (opt), and variants. | en-US, zh-Hans-CN, sl-rozaj |
| **script** | Titlecase 4-character ISO 15924 script code. | Latn, Kore, Deva |
| **url** | RFC 3987 IRI. Supports Unicode characters, schemes (http, ftp), and Punycode for domain names. | https://例子.测试/路径, ftp://user@host/file.txt |
| **email-address** | RFC 5322/6531 compliant. Supports internationalized characters in local and domain parts. | firstname.lastname@example.com, 用户@例子.公司 |
| **phone-number** | E.164 compliant if region is known (e.g., +1...); otherwise, extracted as a raw digit string. | +33612345678, 6505550123 |
| **iban** | ISO 13616-1 International Bank Account Number. Structure varies by country. | DE89370400440532013000 |
| **bic** | ISO 9362 Business Identifier Code (8 or 11 characters). | BNPAFRPPXXX, DEUTDEDBFRA |
| **unit-code** | UCUM (Unified Code for Units of Measure) code. | m, kg, s, Hz |
| **region:US** | Uppercase subdivision code complying to ISO 3166-2:US. | NY, DC, GU |
| **region:FR** | Uppercase subdivision code complying to ISO 3166-2:FR. | 49 (Maine-et-Loire), MQ (Martinique), V (Rhône-Alpes) |
| **region:IE** | Uppercase subdivision code complying to ISO 3166-2:IE. | D (Dublin), C (Connacht), WD (Waterford) |
| **region:GB** | Uppercase subdivision code complying to ISO 3166-2:GB. | WSX (West Sussex), WSM (Westminster), WIL (Wiltshire) |
| **region:IT** | Uppercase subdivision code complying to ISO 3166-2:IT. | RM (Rome), BZ (Bolzano), 82 (Sicily) |
| **region:ES** | Uppercase subdivision code complying to ISO 3166-2:ES. | GA (Galicia), GR (Granada), ML (Melilla) |
| **region:DE** | Uppercase subdivision code complying to ISO 3166-2:DE. | BY (Bayern), BE (Berlin), HH (Hamburg) |
| **region:PT** | Uppercase subdivision code complying to ISO 3166-2:PT. | 11 (Lisbon), 20 (Azores) |
| **region:CA** | Uppercase subdivision code complying to ISO 3166-2:CA. | QC (Quebec), NU (Nunavut), YT (Yukon) |
| **region:MX** | Uppercase subdivision code complying to ISO 3166-2:MX. | JAL (Jalisco), DIF (Distrito Federal), AGU (Aguascalientes) |
| **region:BR** | Uppercase subdivision code complying to ISO 3166-2:BR. | RJ (Rio de Janeiro), DF (Distrito Federal), SP (São Paulo) |
| **region:AU** | Uppercase subdivision code complying to ISO 3166-2:AU. | NSW (New South Wales), VIC (Victoria), ACT (Australian Capital Territory) |
| **region:JP** | Uppercase subdivision code complying to ISO 3166-2:JP. | 13 (Tokyo), 27 (Osaka), 01 (Hokkaidō) |
| **region:KR** | Uppercase subdivision code complying to ISO 3166-2:KR. | 11 (Seoul), 26 (Busan), 41 (Gyeonggi) |