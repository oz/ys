require "http/client"

class ArgParser
  property :argv
  getter :quote, :change

  def initialize(@argv)
  end

  # @return [ArgParser]
  def parse
    help! if show_help?

    case [argv[0], argv.size]
    when ["quote", 2]
      @quote = argv[1]
    when ["change", 4]
      @change = 1.upto(3).map { |i| argv[i] }.to_a
    else
      help!
    end

    self
  end

  # @return [Boolean]
  def show_help?
    argv.size == 0 || argv[0] == "-h" || argv[0] == "--help"
  end

  # @return [NoReturn]
  def help!
    puts "Usage: stock <options...>\n\n"
    puts "  - Get a quote:       stock quote <NAME>"
    puts "  - Change currencies: stock change <FROM> <TO> <AMOUNT>"

    exit(1)
  end
end

class YahooFinance
  BASE_URL = "http://download.finance.yahoo.com/d/quotes.csv"

  def quote(name)
    res = HTTP::Client.get "#{BASE_URL}?s=#{name}&f=a"

    if res.status_code == 200
      res.body
    else
      "HTTP error: #{res.status_code}"
    end
  rescue err
    "Fatal error: #{err}"
  end

  def change(from, to, amount)
    value = quote "#{from}#{to}=X"
    value.to_f * amount.to_f
  end
end

opts = ArgParser.new(ARGV).parse
yf   = YahooFinance.new

if opts.quote
  puts yf.quote(opts.quote)
elsif opts.change
  from, to, amount = opts.change as Array(String)
  puts yf.change(from, to, amount)
end
