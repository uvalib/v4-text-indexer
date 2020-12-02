#!/usr/bin/env ruby
require 'rubygems' 
require 'nokogiri'

#$file_dir="/usr/local/projects/uva/V4-1786/Chiricahua/solr/"
#$des_dir="/usr/local/projects/uva/V4-1786/Chiricahua/Chiricahua-v4-solr/"
#
$file_dir="/usr/local/projects/uva/V4-1786/Studies/studies-v3-solr-docs/studies/"
$des_dir="/usr/local/projects/uva/V4-1786/Studies/"

#@file = File.new($des_dir+"Chiricahua.xml", "wb")
@file = File.new($des_dir+"Studies.xml", "wb")
@file.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
@file.write("<add>\n")

Dir.foreach($file_dir) do | filename|
   next if filename == '.' or filename == '..'
   puts "Convert fields for " + filename

   # Read in xml file
   @doc=Nokogiri::XML(File.read($file_dir+filename))

   # function to change XML attributes name
   def change_attributes_name(old,new)
      @doc.xpath('/add/doc/field[@name="'+old+'"]').attribute("name").value=new
   end

   # map V3 fields to V4 and replace them
   h = {
        :alternate_form_title_text=>"title_alternate_tsearch_stored",
        :author_added_entry_text=>"author_added_entry_tsearch_stored",
        :author_display=>"author_display_tsearch",
        :author_facet=>"author_facet_f_stored",
        :author_sort_facet=>"author_ssort_stored",
        :author_text=>"author_tsearch_stored",
        :content_model_facet=>"content_model_f_stored",
        :content_type_facet=>"content_type_f_stored",
        :digital_collection_facet =>"digital_collection_f_stored",
        :digital_collection_text=>"digital_collection_text_tsearch",
        :datafile_name_display=>"datafile_name_a",
        :editor_display=>"editor_display_tsearch",
        :editor_text=>"editor_tsearch_stored",
        :format_facet=>"format_f_stored",
        :fulltext=>"fulltext_large_multi",
        :heading_text=>"heading_tsearch",
        :journal_title_display=>"journal_title_display_tsearch",
        :journal_title_text=>"journal_title_tsearch_stored",
        :langauge_display=>"language_display_tsearch",
        :langauge_facet=>"language_f_stored",
        :langauge_text=>"language_note_tsearch_stored",
        :location_facet=>"location2_f_stored",
        :main_title_display=>"full_title_tsearchf_stored",
        :note_display=>"note_display_tsearch",
        :note_text=>"note_tsearch_stored",
        :repository_address_display=>"repository_address_a",
        :series_title_display=>"series_title_display_tsearch",
        :series_title_facet=>"series_title_facet_tsearch",
        :series_title_text=>"title_series_tsearchf_stored",
        :shadowed_location_facet=>"shadowed_location_f_stored",
        :source_facet=>"source_f_stored",
        :subject_display=>"subject_display_tsearch", #should be subject_tsearchf_stored, but only one tsearchf field 
        :subject_text=>"subject_text_tsearch",
        :subject_facet=>"subject_tsearchf_stored",
        :subtitle_display=>"subtitle_display_tsearch",
        :subtitle_text=>"title_sub_tsearch_stored",
        :text=>"text_tsearch",
        :title_added_entry_text=>"title_added_entry_tsearch_stored",
        # two title field change for Studies collection--
        #:title_display=>"title_display_tsearch",
        :title_sort_facet=>"title_ssort_stored",
        :title_facet=>"full_title_tsearchf_stored",
        #:title_text=>"title_tsearch_stored",
        :title_display=>"title_tsearch_stored",
        :title_text=>"title_text_tsearch",
        #---
        #:year_display=>"published_display_tsearch_stored",
        :year_display=>"published_date", #this date field can be sorted
        :year_multisort_i=>"published_daterange"
   }
   (0..@doc.xpath('/add/doc/field').length).each { |x|
      old_field=""
      old_field=@doc.xpath('/add/doc/field')[x].attribute("name").value unless @doc.xpath('/add/doc/field')[x].nil?
      new_field=h[old_field.to_sym].nil? ? old_field : h[old_field.to_sym]
      change_attributes_name(old_field,new_field) unless new_field.empty?
   }

   # Add entries
   id= @doc.xpath('/add/doc/field[@name="id"]').text()
   date= @doc.xpath('/add/doc/field[@name="published_date"]').text()
   file= @doc.xpath('/add/doc/field[@name="datafile_name_a"]').text()
   title= @doc.xpath('/add/doc/field[@name="title_ssort_stored"]').text()
   author= @doc.xpath('/add/doc/field[@name="author_ssort_stored"]').text()
   @doc.search('field[@name="id"]').each { |n|
     n.after('
      <field name="pool_f_stored">catalog</field>
      <field name="uva_availability_f_stored">Online</field>
      <field name="anon_availability_f_stored">Online</field>
      <field name="circulating_f">true</field>
      <field name="work_title2_key_sort">'+title.gsub(" ","_")+"/"+ author.gsub(" ","_")+"/Book" +'</field>
      <field name="work_title3_key_sort">'+title.gsub(" ","_")+"//Book" +'</field>
      <field name="url_str_stored">http://xtf.lib.virginia.edu/xtf/view?docId='+file.gsub("/FedoraRepo/text/","")+'</field>
      <field name="data_source_str_stored">etext</field>
      <field name="url_label_str_stored">Read Online</field>
     ')
   }

   # modify published_date format
   @doc.search('/add/doc/field[@name="published_date"]').each do |node|
      pd= @doc.xpath('/add/doc/field[@name="published_date"]')
      node.content=pd.text()+"-01-01T00:00:00Z"
   end

   # remove entries
begin
   @doc.search('/add/doc/field[@name="datafile_name_a"]').remove
   @doc.search('/add/doc/field[@name="content_model_f_stored"]').remove
   @doc.search('/add/doc/field[@name="content_type_f_stored"]').remove
   @doc.search('/add/doc/field[@name="repository_address_a"]').remove
   @doc.search('/add/doc/field[@name="source_f_stored"]').each do |node|
      if node.text== "Digital Library"
        node.remove
      end
   end
end

   @file.write(@doc.search('/add/doc'))

end

@file.write("\n</add>")
@file.close