force_override["postgresql"]["pg_hba_defaults"] = false

force_override["postgresql"]["pg_hba"] = [
    { :type => "local", :db => "all", :user => "postgres", :addr => "",             :method => "ident" },
    { :type => "local", :db => "all", :user => "all",      :addr => "",             :method => "md5" },
    { :type => "host",  :db => "all", :user => "all",      :addr => "127.0.0.1/32", :method => "trust" },
    { :type => "host",  :db => "all", :user => "all",      :addr => "::1/128",      :method => "trust" },
    { :type => "host",  :db => "all", :user => "postgres", :addr => "127.0.0.1/32", :method => "trust" },
    { :type => "host",  :db => "all", :user => "username", :addr => "127.0.0.1/32", :method => "trust" }
]
