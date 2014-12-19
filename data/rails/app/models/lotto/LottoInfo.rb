class LottoInfo
    @name = ""
    @dim = 0           # ex: 649 is 6
    @range = 0         # ex: 649 is 49
    @def_db_ver = ""   # default db version
    @curr_db_ver = ""  # current db version = def db + web data
    
    attr_accessor :name, :dim, :range, :def_db_version, :curr_db_version
end
