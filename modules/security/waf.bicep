targetScope = 'resourceGroup'

@description('AFD WAF policy name (Front Door Standard). Example: almChatbotProdWaf')
param wafPolicyName string

@description('WAF mode: Detection (log only) or Prevention (block).')
@allowed([
  'Detection'
  'Prevention'
])
param mode string = 'Detection'

@description('Allowed countries (ISO 3166-1 alpha-2). Default: Sweden (SE) + United States (US).')
param allowedCountries array = [
  'SE'
  'US'
]

@description('Rate limit threshold: requests per minute per client IP.')
param rateLimitThreshold int = 200

@description('Rate limit window in minutes.')
param rateLimitDurationInMinutes int = 1

@description('Optional: explicit IPs/CIDRs to block. Example: ["1.2.3.4/32","5.6.7.0/24"].')
param blockedIps array = []

@description('Optional: office/VPN IPs/CIDRs to always allow (bypass geo block).')
param allowedOfficeIps array = []

// Common scanner paths
var scannerPathPatterns = [
  '/wp-admin'
  '/wp-login.php'
  '/xmlrpc.php'
  '/.env'
  '/.git'
  '/phpmyadmin'
  '/pma'
  '/adminer'
  '/actuator'
  '/cgi-bin'
]

// SQL Injection patterns
var sqlInjectionPatterns = [
  'union select'
  'select * from'
  'insert into'
  'update set'
  'delete from'
  'drop table'
  'truncate table'
  'or 1=1'
  'exec xp_cmdshell'
  'information_schema'
]

// XSS patterns
var xssPatterns = [
  '<script>'
  'javascript:'
  'onload='
  'onerror='
  'onclick='
  'alert('
  'document.cookie'
  'eval('
  'fromCharCode'
]

// Rule 1: Allow office/VPN (optional)
var allowOfficeRule = length(allowedOfficeIps) > 0 ? [
  {
    name: 'AllowOfficeIPs'
    priority: 1
    ruleType: 'MatchRule'
    action: 'Allow'
    matchConditions: [
      {
        matchVariable: 'RemoteAddr'
        operator: 'IPMatch'
        matchValue: allowedOfficeIps
      }
    ]
  }
] : []

// Rule 10: Block requests NOT from allowed countries (SE + US)
var blockNonAllowedCountriesRule = [
  {
    name: 'BlockNonAllowedCountries'
    priority: 10
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'RemoteAddr'
        operator: 'GeoMatch'
        matchValue: allowedCountries
        negateCondition: true
      }
    ]
  }
]

// Rule 20: Block explicit bad IPs (optional)
var blockBadIpsRule = length(blockedIps) > 0 ? [
  {
    name: 'BlockBadIPs'
    priority: 20
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'RemoteAddr'
        operator: 'IPMatch'
        matchValue: blockedIps
      }
    ]
  }
] : []

// Rule 30: Block common scanner paths
var blockScannerPathsRule = [
  {
    name: 'BlockScannerPaths'
    priority: 30
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'RequestUri'
        operator: 'Contains'
        matchValue: scannerPathPatterns
        transforms: [
          'Lowercase'
        ]
      }
    ]
  }
]

// Rule 40-41: Block TRACE/TRACK
var blockTraceTrackRules = [
  {
    name: 'BlockTRACE'
    priority: 40
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'RequestMethod'
        operator: 'Equal'
        matchValue: [
          'TRACE'
        ]
      }
    ]
  }
  {
    name: 'BlockTRACK'
    priority: 41
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'RequestMethod'
        operator: 'Equal'
        matchValue: [
          'TRACK'
        ]
      }
    ]
  }
]

// Rule 50: Block SQL Injection patterns
var sqlInjectionRule = [
  {
    name: 'BlockSQLiPatterns'
    priority: 50
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'QueryString'
        operator: 'Contains'
        matchValue: sqlInjectionPatterns
        transforms: [
          'Lowercase'
          'Trim'
        ]
      }
    ]
  }
]

// Rule 51: Block XSS patterns
var xssProtectionRule = [
  {
    name: 'BlockXSSPatterns'
    priority: 51
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'QueryString'
        operator: 'Contains'
        matchValue: xssPatterns
        transforms: [
          'Lowercase'
          'UrlDecode'
        ]
      }
    ]
  }
]

// Rule 100: Rate limit per client IP
var rateLimitRule = [
  {
    name: 'RateLimitPerIP'
    priority: 100
    ruleType: 'RateLimitRule'
    action: 'Block'
    rateLimitDurationInMinutes: rateLimitDurationInMinutes
    rateLimitThreshold: rateLimitThreshold
    matchConditions: [
      {
        matchVariable: 'RemoteAddr'
        operator: 'IPMatch'
        matchValue: [
          '0.0.0.0/0'
        ]
      }
    ]
  }
]

// Final rules order
var customRules = concat(
  allowOfficeRule,
  blockNonAllowedCountriesRule,
  blockBadIpsRule,
  blockScannerPathsRule,
  blockTraceTrackRules,
  sqlInjectionRule,
  xssProtectionRule,
  rateLimitRule
)

resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: wafPolicyName
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: mode
    }
    customRules: {
      rules: customRules
    }
  }
}

output wafPolicyId string = wafPolicy.id
