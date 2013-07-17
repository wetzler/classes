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
collection = "item_purchases"
projectID = "51e72b4f897a2c2a00000000"
key = "9fe092835a64548514a49448f7a152b946d6f4a0d69a2a6bd9c00e8020e8ab3c16ae3e3309a7e7765677478ca3fddb1c4bc0f9398137375f3b8542a2766de09e4dd40e44688f78dbcfddabf61b43876048a82b16d21d0891fa892f0b44c61771ca5c126dfc18d3fc16df5c81f6bcc087"



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

bulk_results = {collection => bulk_events}
                           
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