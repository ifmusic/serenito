#
input
{
stdin{
    codec => multiline {
     # Grok pattern names are valid! :)
      pattern => "^%{TIME:timestamp} "
      negate => true
      what => "previous"
    }
}
#file{
	#path=>"/usr/local/Cellar/logstash/7.2.0/bin/test.log"
#  path=>"/Users/ifmusic/Desktop/logs/JBossLog/*"
#	mode=>"read"
#	  codec => multiline {
     # Grok pattern names are valid! :)
#      pattern => "^%{TIME:timestamp} "
#      negate => true
#      what => "previous"
#    }
#    file_completed_action =>"log"
#    file_completed_log_path =>"/usr/local/Cellar/logstash/7.2.0/bin/test.path.log"
#    file_chunk_size => "65536"
#    sincedb_path => "/dev/null"
#    start_position => "beginning"
#}
}

filter {
  grok {
    match => { "message" => "%{TIME:timestamp} %{LOGLEVEL:loglevel} \[%{DATA:method}\] \(%{DATA}\) %{GREEDYDATA:xml_data}" }
  }
  #obtengo la fecha , desde el nombre de archivo
  grok {
    match => { "path" => "%{DATA}Danone\-ThemisLacteos\_PM\.log\.(?<date>%{YEAR}-%{MONTHNUM}-%{MONTHDAY})" }
  }
  #Junto la fecha y la hora
  mutate {
    replace => { "timestamp" => "%{date} %{timestamp}" }
  }
  date
  {
  match => [ "timestamp",  "yyyy-MM-dd HH:mm:ss,SSS" ]
  }
   mutate {
    remove_field => [ "date","timestamp","message" ]
  }

#Tratamiento de mensaje AMQ / XML
if "Mensaje de entrada" in [xml_data]
{ 
  grok {
    match => { "xml_data" => "Mensaje de entrada:\ Q\|%{NUMBER:iDoc}" }
  }
  mutate {
    add_tag => [ "message_in", "sap", "amq"]
  }
}
else 
{
  #parseo del XML en xml_data
  xml {
      source => "xml_data"
      target => "doc"
    }

  mutate {
    add_tag => [ "ws_call" ]
  }
}

}

output
{
stdout{codec=>"rubydebug"}

#	elasticsearch {
#		hosts => "localhost:9200"
#		user => "elastic"
#		password => "changeme"
#	}
}
