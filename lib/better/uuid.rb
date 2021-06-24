require "uuidtools"


module Better
  module UUID
    extend self

    NULL_NAMESPACE = UUIDTools::UUID.parse_int(0)
    DNS_NAMESPACE  = UUIDTools::UUID_DNS_NAMESPACE
    URL_NAMESPACE  = UUIDTools::UUID_URL_NAMESPACE
    OID_NAMESPACE  = UUIDTools::UUID_OID_NAMESPACE
    X500_NAMESPACE = UUIDTools::UUID_X500_NAMESPACE

    UUID_REGEXP = Regexp.new("^([0-9a-f]{8})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{4})-([0-9a-f]{12})$")

    def uuid
      UUIDTools::UUID.random_create.to_s
    end

    def uuid_v4
      UUIDTools::UUID.random_create.to_s
    end

    def uuid_v5(uuid_namespace, name)
      UUIDTools::UUID.sha1_create(uuid_namespace, name).to_s
    end

    def include?(str)
      return false unless str.kind_of?(String)
      str.match?(UUID_REGEXP)
    end
  end
end
