require_relative '../lib/better.rb'
puts Better::UUID::NULL_NAMESPACE
puts Better::UUID::URL_NAMESPACE
puts Better::UUID::PROTETIKO_NAMESPACE
puts Better::UUID.uuid_v5("230c998b-50ab-44e2-9217-02454f6ef7d3", 'protetiko.io')

5.times { puts Better::UUID.uuid_v4 }

5.times { puts Better::UUID.uuid_v5(Better::UUID::PROTETIKO_NAMESPACE, 'protetiko.io')}
