require "test_helper"

UUID = Better::UUID

class UUIDTest < Minitest::Test
  def test_uuid
    uuid = Better::UUID.uuid
    uuid_v4 = Better::UUID.uuid_v4
    uuid_v5 = Better::UUID.uuid_v5(Better::UUID::DNS_NAMESPACE, 'protetiko.io')

    assert_equal "00000000-0000-0000-0000-000000000000", Better::UUID::NULL_NAMESPACE.to_s
    assert_equal "6ba7b810-9dad-11d1-80b4-00c04fd430c8", Better::UUID::DNS_NAMESPACE.to_s
    assert_equal "6ba7b811-9dad-11d1-80b4-00c04fd430c8", Better::UUID::URL_NAMESPACE.to_s
    assert_equal "6ba7b812-9dad-11d1-80b4-00c04fd430c8", Better::UUID::OID_NAMESPACE.to_s
    assert_equal "6ba7b814-9dad-11d1-80b4-00c04fd430c8", Better::UUID::X500_NAMESPACE.to_s

    refute Better::UUID.include?(nil)
    refute Better::UUID.include?("")

    assert Better::UUID.include?(uuid)
    assert Better::UUID.include?(uuid_v4)
    assert Better::UUID.include?(uuid_v5)

    assert_equal "2e3de1df-deb8-5a7d-a353-fcb633d1d890", uuid_v5
  end
end

