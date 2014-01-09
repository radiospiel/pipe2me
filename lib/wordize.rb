#!/usr/bin/env ruby
require 'digest/md5'

module Wordize
  # -- returns an identifier for the current wordize version.
  # -- When changing the algorithm or the word tables we must 
  # -- change this value.
  VERSION = 0

  def self.wordize(i32)
    case i32
    when Fixnum
      i32 %= 0xffffffff
    else
      # 8 hexdigits are enough for a 32 bit number, which is more than enough
      # for our ~10k names
      s32 = Digest::MD5.hexdigest(word)[0,8]
      i32 = s32.to_i(16)
    end

    parts = [MOODS, COLORS, ANIMALS].map do |words|
      # get remainder for table in this round.
      idx = i32 % words.length
      i32 = (i32 - idx) / words.length

      words[idx]
    end

    parts.join("-")
  end

  MOODS = %w{
    great
    funny
    strong
    smiling
    cute
    pretty
    handsome
    clever
    bright
    smart
    charming
    handsome
  }

  COLORS = %w{
    white
    pink
    red
    orange
    brown
    yellow
    gray
    green
    blue
    black
    violet
    snowwhite
    peach
    ivory
    azure
    lavender
    olive
    lemon
    lime
    golden
    silver
    rosy
  }

  ANIMALS = %w{
    cat
    puppy
    dolphin
    koala
    lamb
    hamster
    dog
    fish
    bird
    parrot
    mouse
    bear
    panda
    unicorn
    horse
    rabbit
    kangaroo
    tiger
    panda 
    lion
    giraffe
    leopard
    monkey
    horse
    pony
    hippo
    owl
    turtle
    elephant
    shark
    whale
  }
end

if __FILE__ == $0 
  def assert_equal(expected, actual)
    raise "#{expected} should be #{actual}" unless expected == actual
  end

  assert_equal(Wordize.wordize("kjhskjsh"), "great-azure-dolphin")
  assert_equal(Wordize.wordize("kjhskjshkjhskjsh"), "smart-green-turtle")

  assert_equal(Wordize.wordize("greatxx-orangexx-pandaxx"), "funny-gray-elephant")
  assert_equal(Wordize.wordize("greatxx-orangexx-pandayy"), "cute-lemon-horse")
end
