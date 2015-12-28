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
    puts "Usage: #{PROGRAM_NAME} <options...>\n\n"
    puts "  - Get a quote:       #{PROGRAM_NAME} quote <NAME>"
    puts "  - Change currencies: #{PROGRAM_NAME} change <FROM> <TO> <AMOUNT>"

    exit(1)
  end
end

class YahooFinance
  API_HOST = "download.finance.yahoo.com"

  def quote(name : String)
    res = client.get quote_api(name)

    if res.status_code == 200
      res.body
    else
      "HTTP error: #{res.status_code}"
    end
  rescue err
    "Error: #{err}"
  end

  def change(from, to, amount)
    value = quote "#{from}#{to}=X"
    value.to_f * amount.to_f
  end

  def client
    HTTP::Client.new(API_HOST).tap do |client|
      client.connect_timeout = 1
      client.read_timeout = 1
    end
  end

  def quote_api(name : String)
    "http://#{API_HOST}/d/quotes.csv?s=#{name}&f=a"
  end
end

opts = ArgParser.new(ARGV).parse
yf = YahooFinance.new

if opts.quote
  puts yf.quote(opts.quote.to_s)
elsif opts.change
  from, to, amount = opts.change as Array(String)
  puts yf.change(from, to, amount)
end
