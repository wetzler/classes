require 'rubygems'
require 'csv'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'
require 'time'
require 'date'



# Here you can specify which Keen Event Collections should be used for the databed (where to send events) 
# This only applies if you send the data to Keen. There is another option below to output the events to file. 
collection = "purchased_items"
projectID = "51ad19dd3843315fe9000001"
key = "25fde0625e602e3acd431bd309f82339d7e4d06c82dd9683eac808bca5c6c2041bc688743b08dba0d42fa95156b4b40323e9cd21540e6fef37f332dee19ad506f6f4e457dcad08517ebd0399d55050146eab69bbd6bb7fd2c974119822d2d1d2ea85f50cc2326c54ecd3a73e117142c3"



###########################
# Generate Event Data #
###########################
# Convert a CSV file to JSON

bulk_events=[]

csv_text = File.read('purchases.csv')
csv = CSV.parse(csv_text, :headers => true)

csv.each do |row|
  
 puts row[0]
 # require 'ruby-debug'; debugger;
 # puts Time.parse(row[0])
 puts timestamp = DateTime.strptime(row[0], "%m/%d/%y").to_date.iso8601
    eventhash = {
               :keen => {
                  :timestamp => timestamp,
                  },
               :user => {
                   :name => {
                       :first => row[1],
                       :last => row[2],
                       :full => row[3],
                       }
                   },       
               :item => {
                   :name => row[4],
                   :price => row[5].to_f
                   },
               :payment_method => row[6],
               }
  
  bulk_events << eventhash
  
end

puts bulk_events

######################################## 
# Send all the results to Keen
########################################

bulk_results = {"purchases" => bulk_events}
                           
        # Required info to post events in Keen
        uri = URI.parse("http://api.keen.io/")
        http = Net::HTTP.new(uri.host, uri.port)

        bulk_results_post_request = Net::HTTP::Post.new("/3.0/projects/#{projectID}/events")
        bulk_results_post_request.add_field("Authorization", key) 
        bulk_results_post_request.add_field("Content-Type", "application/json")
        
        # Convert the ruby hash to json format
        bulk_results_post_request.body = bulk_results.to_json
        response = http.request(bulk_results_post_request)
        
        puts response.body