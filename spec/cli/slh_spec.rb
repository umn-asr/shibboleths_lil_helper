require 'spec_helper'

describe Slh::Cli do
  it "should output documentation when there aren't any subcommands specified " do
    expect {
      Slh::Cli.start
    }.to_not raise_exception
  end
end
