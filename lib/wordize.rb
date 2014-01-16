#!/usr/bin/env ruby

module Wordize
  def self.wordize
    i32 = rand(0xffffffff)

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

module Wordize::Etest
  def test_wordize_rnd
    w1 = Wordize.wordize
    w2 = Wordize.wordize

    assert w1 =~ /[a-z]+-[a-z]+-[a-z]+/
    assert w2 =~ /[a-z]+-[a-z]+-[a-z]+/
    assert_not_equal(w1, w2)
  end
end
