# Some helpers to make paperclip rails 7 compatible
require "cgi"

module URI
  class << self
    # Rough compatibility with old URI.escape
    def escape(str)
      CGI.escape(str.to_s).gsub("+", "%20").gsub("%2F", "/")
    end

    def unescape(str)
      CGI.unescape(str.to_s)
    end
  end
end

Rails.application.config.to_prepare do
  next unless defined?(ActiveModel::Errors)

  unless ActiveModel::Errors.instance_method(:method).owner == Module # avoid constant redefinition warnings
    module PaperclipErrorsCompat
      def add(attribute, message = :invalid, *args, **kw)
        # Paperclip passes a 3rd positional hash of options; convert it to kwargs.
        if args.first.is_a?(Hash)
          kw = kw.merge(args.first)
          args = []
        end
        super(attribute, message, **kw)
      end
    end

    ActiveModel::Errors.prepend(PaperclipErrorsCompat)
  end
end