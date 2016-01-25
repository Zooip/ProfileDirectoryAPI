class Gram::SoceId

    def self.next_soce_id_seq_value
      # This returns a PGresult object [http://rubydoc.info/github/ged/ruby-pg/master/PGresult]
      result = connection.execute("SELECT nextval('soce_id_seq')")

      result[0]['nextval']
    end

    def self.set_soce_id_seq_value_to_max(value=0)
      result = connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, ["SELECT setval('soce_id_seq',(SELECT GREATEST((SELECT MAX(soce_id) FROM profiles),?)))",value]))
    end


    private
      def self.connection
        Gram::Base.connection
      end
end