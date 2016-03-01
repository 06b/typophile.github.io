task :default do
  puts "There's no default task; either do a convert or a reindex (or both)"
end

task :convert do
  ruby "node2json.rb"
end

task :reindex do
  require './models/article.rb'
  ArticleRepository.create_index! force:true 
  sh "java -jar elasticsearch-fileimport-0.6-SNAPSHOT-jar-with-dependencies.jar file_import_settings.yml"
end
