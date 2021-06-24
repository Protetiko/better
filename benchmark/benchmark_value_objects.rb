# http://blog.honeybadger.io/how-openstruct-and-hashes-can-kill-performance/
#
# It's not faire to use `Hash.new.merge(data)` if you can `Hash[data]`.
# `Hash[data]` is way faster! Lets compare!
#
# Read more: http://ruby-doc.org/core-2.2.0/Hash.html#method-c-5B-5D
#
# [UPDATE]
#
# * Disable GC for each report

require 'benchmark/ips'
require 'ostruct'
require 'virtus'
require_relative '../lib/better'
require_relative 'alternative_implementations/value_object.rb'

$stdout = File.new("benchmark-#{DateTime.now}.log", 'w')
$stdout.sync = true

# Enable and start GC before each job run. Disable GC afterwards.
#
# Inspired by https://www.omniref.com/ruby/2.2.1/symbols/Benchmark/bm?#annotation=4095926&line=182
class GCSuite
  def warming(*)
    run_gc
  end

  def running(*)
    run_gc
  end

  def warmup_stats(*)
  end

  def add_report(*)
  end

  private

  def run_gc
    GC.enable
    GC.start
    GC.disable
  end
end

suite = GCSuite.new

data = { x: 100, y: 200 }

PointStruct = Struct.new(:x, :y)

class FakedPointStruct
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
end

class PointClass
  attr_accessor :x, :y
  def initialize(args)
    @x = args.fetch(:x) # NOTE: Hash#fetch -> performance impact
    @y = args.fetch(:y)
  end
end

class BetterPoint < Better::ValueObject
  field :x
  field :y
end

class BetterImmutablePoint < Better::ImmutableValueObject
  field :x
  field :y
end

class PointVO < ValueObject
  field :x
  field :y
end

class PointVO2 < ValueObject2
  field :x
  field :y
end

class PointVO3 < ValueObject3
  field :x
  field :y
end

class PointVO4 < ValueObject4
  field :x
  field :y
end

class ImmutablePoint < ImmutableValueObject
  field :x
  field :y
end

class VirtusPoint
  include Virtus.model

  attribute :x#, String
  attribute :y#, Integer
end

puts "\n\nINITIALIZATION =========="

Benchmark.ips do |x|
  x.config(suite: suite)

  # Create Objects as a reference value
  x.report("Object.new") { Object.new }

  x.report("FakedPointStruct") { FakedPointStruct.new(100, 200) }
  x.report("PointStruct") { PointStruct.new(100, 200) }
  x.report("Hash[]") { Hash[data] }
  x.report("PointClass") { PointClass.new(data) }
  x.report("Hash#merge") { Hash.new.merge(data) }
  x.report("OpenStruct") { OpenStruct.new(data) }
  x.report("BetterPoint") { BetterPoint.new(data) }
  x.report("BetterImmutablePoint") { PointVO2.new(data) }
  x.report("ValueObject") { BetterPoint.new(data) }
  x.report("ValueObject2") { PointVO2.new(data) }
  x.report("ValueObject3") { PointVO3.new(data) }
  x.report("ValueObject4") { PointVO4.new(data) }
  x.report("ImmutablePoint") { ImmutablePoint.new(data) }
  x.report("Virtus") { VirtusPoint.new(data) }
end

puts "\n\nREAD =========="

faked_point_struct = FakedPointStruct.new(100, 200)
point_struct = PointStruct.new(100, 200)
point_class = PointClass.new(data)
point_hash = Hash[data]
point_open_struct = OpenStruct.new(data)
better_point = BetterPoint.new(data)
better_immutable_point = BetterImmutablePoint.new(data)
point_vo = PointVO.new(data)
point_vo = PointVO.new(data)
point_vo2 = PointVO2.new(data)
point_vo3 = PointVO3.new(data)
point_vo4 = PointVO4.new(data)
immutable_point = ImmutablePoint.new(data)
virtus_point = VirtusPoint.new(data)

Benchmark.ips do |x|
  x.config(suite: suite)

  x.report("FakedPointStruct") { faked_point_struct.x }
  x.report("PointStruct") { point_struct.x }
  x.report("PointClass") {point_class.x }
  x.report("Hash#fetch") { point_hash.fetch(:x) }
  x.report("Hash#[]") { point_hash[:x] }
  x.report("OpenStruct") {point_open_struct.x }
  x.report("BetterPoint#[]") { better_point[:x] }
  x.report("BetterPoint.x") { better_point.x }
  x.report("BetterImmutable#[]") { better_immutable_point[:x] }
  x.report("BetterImmutable.x") { better_immutable_point.x }
  x.report("ValueObject#[]") { point_vo[:x] }
  x.report("ValueObject.x") { point_vo.x }
  x.report("ValueObject2#[]") { point_vo2[:x] }
  x.report("ValueObject2.x") { point_vo2.x }
  x.report("ValueObject3#[]") { point_vo3[:x] }
  x.report("ValueObject3.x") { point_vo3.x }
  x.report("ValueObject4#[]") { point_vo4[:x] }
  x.report("ValueObject4.x") { point_vo4.x }
  x.report("ImmutablePoint#[]") { immutable_point[:x] }
  x.report("ImmutablePoint.x") { immutable_point.x }
  x.report("Virtus") { virtus_point.x }
end


puts "\n\nWRITE =========="

Benchmark.ips do |x|
  x.config(suite: suite)

  x.report("FakedPointStruct") { faked_point_struct.x = 1 }
  x.report("PointStruct") { point_struct.x = 1 }
  x.report("PointClass") {  point_class.x = 1 }
  x.report("Hash") { point_hash[:x] = 1 }
  x.report("OpenStruct") {  point_open_struct.x = 1 }
  x.report("BetterPoint#[]") { better_point[:x] = 1 }
  x.report("BetterPoint.x") { better_point.x = 1 }
  x.report("ValueObject#[]") { point_vo[:x] = 1 }
  x.report("ValueObject.x") { point_vo.x = 1 }
  x.report("ValueObject2#[]") { point_vo2[:x] = 1 }
  x.report("ValueObject2.x") { point_vo2.x = 1 }
  x.report("ValueObject3#[]") { point_vo3[:x] = 1 }
  x.report("ValueObject3.x") { point_vo3.x = 1 }
  x.report("ValueObject4#[]") { point_vo4[:x] = 1 }
  x.report("ValueObject4.x") { point_vo4.x = 1 }
  x.report("Virtus") { virtus_point.x = 1 }
end

