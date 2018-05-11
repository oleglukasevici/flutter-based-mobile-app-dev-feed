package org.rm3l.tools.reverseproxy.services.ip_geo.dazzlepod

import com.fasterxml.jackson.annotation.JsonIgnore
import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import org.rm3l.tools.reverseproxy.resources.ip_geo.NetWhoisInfo

/* === dazzlepod.com ===
* {
* "ip": "216.58.208.234",
* "prefix": "216.58.208.0/24",
* "country_code": "US",
* "asn": "AS15169",
* "city": "Mountain View",
* "country": "United States",
* "region": "California",
* "hostname": "par10s22-in-f10.1e100.net",
* "longitude": -122.0574,
* "latitude": 37.4192,
* "organization": "GOOGLE - Google Inc.,US"
* }
*/
@Suppress("MemberVisibilityCanPrivate")
@JsonIgnoreProperties(ignoreUnknown = true)
data class DazzlepodNetWhoisInfo(val ip: String? = null,
                                 val prefix: String? = null,
                                 val country_code: String? = null,
                                 val asn: String? = null,
                                 val city: String? = null,
                                 val country: String? = null,
                                 val region: String? = null,
                                 val hostname: String? = null,
                                 val longitude: String? = null,
                                 val latitude: String? = null,
                                 val organization: String? = null): NetWhoisInfo {

    @JsonIgnore
    override fun isNone(): Boolean {
        return asn == null
                && city == null
                && country == null
                && country_code == null
                && hostname == null
                && ip == null
                && latitude == null
                && longitude == null
                && organization == null
                && prefix == null
                && region == null
    }
}