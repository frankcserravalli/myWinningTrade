require 'spec_helper'

describe "helper methods" do
  describe "scramble_token" do
    before do
      @token = scramble_token(Time.now, 123)
    end

    it "returns a string" do
      @token.should be_a String
    end
  end

  describe "unscramble_token" do
    before do
      @time = Time.now

      @token = scramble_token(@time, 123)
    end

    it "unscrambles the token so I'm returned the time" do
      unscrambled_token = unscramble_token(@token)

      unscrambled_token.should.eql? @time
    end

    it "unscrambles the token and returns both time and user_id" do
      unscrambled_token = unscramble_token(@token, true)

      unscrambled_token[0].should.eql? @time

      unscrambled_token[1].should.eql? 123
    end
  end
end