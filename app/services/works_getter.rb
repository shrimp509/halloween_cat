class WorksGetter
  class << self
    def all
      JSON.load(File.read('app/models/works.json'))
    end
  end
end