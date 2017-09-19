require 'pp'
require 'json'
require 'net/http'

require_relative 'ecobee/http'
require_relative 'ecobee/register'
require_relative 'ecobee/thermostat'
require_relative 'ecobee/token'
require_relative 'ecobee/version'

module Ecobee

  class HTTPError < StandardError;
    def initialize(message, status)
      @message = message
      @status = status
  end

  class AuthError < HTTPError ; end

  class RetryAuthError < AuthError ; end

  API_HOST = 'api.ecobee.com'
  API_PORT = 443
  API_URI_BASE= "https://#{API_HOST}:#{API_PORT}"

  CONTENT_TYPE = ['application/json', { 'charset' => 'UTF-8' }]

  DEFAULT_POLL_INTERVAL = 30

  DEFAULT_FILES = [
    '~/Library/Mobile Documents/com~apple~CloudDocs/.ecobee_token',
    '~/.ecobee_token'
  ]

  AUTH_ERRORS = %w{
    authorization_expired
    authorization_pending
    invalid_client
    slow_down
  }

  FAN_MODES = %w{auto on}

  HVAC_MODES = %w{auto auxHeatOnly cool heat off}

  MAX_LOG_LENGTH = 1200

  AUTH_PAD = 30
  REFRESH_PAD = 240

  SCOPES = [:smartWrite, :smartRead]
  DEFAULT_SCOPE = SCOPES[1]

  def self.FanMode(mode)
    { 'auto'        => 'Auto',
      'on'          => 'On'
    }.fetch(mode, 'Unknown')
  end

  def self.Mode(mode)
    { 'auto'        => 'Auto',
      'auxHeatOnly' => 'Aux Heat Only',
      'cool'        => 'Cool',
      'heat'        => 'Heat',
      'off'         => 'Off'
    }.fetch(mode, 'Unknown')
  end

  def self.Model(model)
    { 'idtSmart'    => 'ecobee Smart',
      'idtEms'      => 'ecobee Smart EMS',
      'siSmart'     => 'ecobee Si Smart',
      'siEms'       => 'ecobee Si EMS',
      'athenaSmart' => 'ecobee3 Smart',
      'athenaEms'   => 'ecobee3 EMS',
      'corSmart'    => 'Carrier or Bryant Cor',
    }.fetch(model, "Unknown (#{model})")
  end

  def self.ResponseCode(code)
    {  0 => 'Success',
       1 => 'Authentication failed.',
       2 => 'Not authorized.',
       3 => 'Processing error.',
       4 => 'Serialization error.',
       5 => 'Invalid request format.',
       6 => 'Too many thermostat in selection match criteria.',
       7 => 'Validation error.',
       8 => 'Invalid function.',
       9 => 'Invalid selection.',
      10 => 'Invalid page.',
      11 => 'Function error.',
      12 => 'Post not supported for request.',
      13 => 'Get not supported for request.',
      14 => 'Authentication token has expired. Refresh your tokens.',
      15 => 'Duplicate data violation.',
      16 => 'Invalid token. Token has been deauthorized by user. You must ' +
            're-request authorization.'
    }.fetch(code.to_i, 'Unknown Error.')
  end

  def self.Selection(arg = {})
    { 'selection' => {
        'selectionType' => 'registered',
        'selectionMatch' => '',
        'includeRuntime' => 'false',
        'includeExtendedRuntime' => 'false',
        'includeElectricity' => 'false',
        'includeSettings' => 'false',
        'includeLocation' => 'false',
        'includeProgram' => 'false',
        'includeEvents' => 'false',
        'includeDevice' => 'false',
        'includeTechnician' => 'false',
        'includeUtility' => 'false',
        'includeAlerts' => 'false',
        'includeWeather' => 'false',
        'includeOemConfig' => 'false',
        'includeEquipmentStatus' => 'false',
        'includeNotificationSettings' => 'false',
        'includeVersion' => 'false',
        'includeSensors' => 'false',
      }.merge(Hash[*arg.map { |k,v| [k.to_s, v.to_s] }.flatten])
    }
  end

end
