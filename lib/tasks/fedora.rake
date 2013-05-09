
require 'find'

ENABLE_SOLR_UPDATES = false
ALLOWED_DOCUMENT_TYPES = ['Text', 'Image', 'Audio', 'Video', 'Other']

namespace :fedora do
	
	task :ingest_one => :environment do

		corpus_rdf  = ARGV[1] unless ARGV[1].nil?

		if (corpus_rdf.nil?) || (! File.exists?(corpus_rdf))
			puts "Usage: rake fedora:ingest_one <corpus rdf file"
			exit 1
		end

		ingest_rdf_file(File.dirname(corpus_rdf), corpus_rdf)

	end

	task :ingest => :environment do

		corpus_dir  = ARGV[1] unless ARGV[1].nil?

		if (corpus_dir.nil?) || (! Dir.exists?(corpus_dir))
			puts "Usage: rake fedora:ingest <corpus folder>"
			exit 1
		end

		puts "Ingesting corpus from " + corpus_dir.to_s

		Dir.glob( corpus_dir + '/*-metadata.rdf') do |rdf_file|
			ingest_rdf_file(corpus_dir, rdf_file)
		end
	end

	task :clear => :environment do

		puts "Emptying Fedora"

		Item.find_each do | item |
			puts item.pid.to_s
			item.delete
		end

		Document.find_each do | doc |
			puts doc.pid.to_s
			doc.delete
		end

	end

	def ingest_rdf_file(corpus_dir, rdf_file)

		puts "Ingesting item: " + rdf_file.to_s

		item = Item.new
		item.descMetadata.graph.load( rdf_file, :format => :ttl )
		item.label = item.descMetadata.graph.statements.first.subject
		item.save!

		puts "Item= " + item.pid.to_s
		#Text
		query = RDF::Query.new({
			:document => {
				RDF::URI("http://purl.org/dc/terms/type") => :type,
				RDF::URI("http://purl.org/dc/terms/identifier") => :identifier,
				RDF::URI("http://purl.org/dc/terms/source") => :source,
				RDF::URI("http://purl.org/dc/terms/title") => :title
			}
		})

		query.execute(item.descMetadata.graph).each do |result|
			filepath = corpus_dir + "/" + result.identifier.to_s
			if ALLOWED_DOCUMENT_TYPES.include? result.type.to_s
				Find.find(corpus_dir) do |path|
					if File.basename(path).eql? result.identifier.to_s and File.file? path 
						doc = Document.new
						doc.descMetadata.graph.load( rdf_file, :format => :ttl )
						doc.label = result.source
						doc.item = item
						doc.file.content = File.open(path)
						doc.save
						puts "#{result.type.to_s} Document= " + doc.pid.to_s
						break
					end
				end
			end
		end

	end

end