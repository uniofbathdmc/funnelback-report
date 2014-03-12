require 'net/http'
require 'net/https'

require 'nokogiri'
require 'open-uri'

# require 'sinatra'

# Set up HTTP client to get report page and get past HTTP Auth
http = Net::HTTP.new(ENV['FUNNELBACK_URL'],8443)
req = Net::HTTP::Get.new("/search/admin/analytics/Dashboard?atab=Analyse&collection=website")
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
req.basic_auth(ENV['FUNNELBACK_USERNAME'], ENV['FUNNELBACK_PASSWORD'])
response = http.request(req)

# Save to disk so that Nokogiri can view it
open("website-report.html", "wb") { |file|
    file.write(response.body)
}

# Attempt to get the Usage summary chart
# Go to page that has chart and link to download
req = Net::HTTP::Get.new('/search/admin/analytics/Dashboard?r=SUMMARY&collection=website&time=l90d&timeframe=day&startDate=20131211&endDate=20140311')
req.basic_auth ENV['FUNNELBACK_USER'], ENV['FUNNELBACK_PW']
response = http.request(req)

open("usage-summary-chart.html", "wb") { |file|
    file.write(response.body)
}


chart_page = File.open("usage-summary-chart.html")
chart_doc = Nokogiri::HTML(chart_page)
chart_page.close

chart_url = chart_doc.css("div#download a")[2]['href'].gsub(/\s+/, "")

req = Net::HTTP::Get.new('/search/admin/analytics/' + chart_url)
req.basic_auth ENV['FUNNELBACK_USER'], ENV['FUNNELBACK_PW']
response = http.request(req)

open("usage-summary-chart.png", "wb") { |file|
    file.write(response.body)
}

# Look at the rest of the report
report_page = File.open("website-report.html")
doc = Nokogiri::HTML(report_page)
report_page.close

# Summary
summary_table = doc.css('div.summary_report table')
# puts summary_table


def fetch_funnelback_content(url, output_filename)

end	
