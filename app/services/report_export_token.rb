# frozen_string_literal: true

# Short-lived signed token authorizing one specific report download.
#
# The SPA requests a token with a CSRF-protected POST (where the request is
# validated and errors come back as JSON), then navigates the browser to a
# GET URL carrying the token so the CSV can stream straight to disk. The GET
# can't be forged cross-site because the token is only obtainable through the
# POST, and the token is bound to the requesting user, organization, report
# and date range so it is useless to anyone else even if it leaks (e.g. via
# access logs).
class ReportExportToken
  PURPOSE = 'report_export'
  EXPIRES_IN = 2.minutes

  Payload = Struct.new(:user_id, :organization_id, :report_key, :start_date, :end_date, keyword_init: true)

  def self.generate(user:, organization:, report_key:, start_date:, end_date:)
    verifier.generate(
      {
        'user_id' => user.id,
        'organization_id' => organization.id,
        'report_key' => report_key,
        'start_date' => start_date.iso8601,
        'end_date' => end_date.iso8601
      },
      expires_in: EXPIRES_IN,
      purpose: PURPOSE
    )
  end

  # Returns a Payload, or nil if the token is missing, tampered with,
  # expired, or malformed.
  def self.verify(token)
    return nil unless token.is_a?(String) && token.present?

    data = verifier.verified(token, purpose: PURPOSE)
    return nil unless data.is_a?(Hash)

    Payload.new(
      user_id: data.fetch('user_id'),
      organization_id: data.fetch('organization_id'),
      report_key: data.fetch('report_key'),
      start_date: Date.iso8601(data.fetch('start_date')),
      end_date: Date.iso8601(data.fetch('end_date'))
    )
  rescue ArgumentError, KeyError, JSON::ParserError
    nil
  end

  def self.verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(
      Rails.application.key_generator.generate_key(PURPOSE),
      digest: 'SHA256',
      serializer: JSON
    )
  end
  private_class_method :verifier
end
