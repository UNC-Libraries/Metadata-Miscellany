# from https://stackoverflow.com/a/172149/4577051
# minor modification to make it read XML files from a local directory instaed of web path

require "rexml/document"
require "net/http"
include REXML
class NodeAnalyzer
  @@fullPathToFilesToSubNodesNamesToCardinalities = Hash.new()
  @@fullPathsToFiles = Hash.new() #list of files in which a fullPath node is detected
  @@fullPaths = Array.new # all fullpaths sorted alphabetically
  attr_reader :name, :father, :subNodesAnalyzers, :indent, :file, :subNodesNamesToCardinalities
  def initialize(aName="", aFather=nil, aFile="")
    @name = aName; @father = aFather; @subNodesAnalyzers = []; @file = aFile
    @subNodesNamesToCardinalities = Hash.new(0)
    #    if aFather && !aFather.name.empty? then @indent = "  " else @indent = "" end
    if aFather && !aFather.name.empty? then @indent = aFather.name + '/' else @indent = "" end
    if aFather
      @indent = @father.indent + self.indent
      @father.subNodesAnalyzers << self
      @father.updateSubNodesNamesToCardinalities(@name)
    end
  end
  @@nodesRootAnalyzer = NodeAnalyzer.new
  def NodeAnalyzer.nodesRootAnalyzer
    return @@nodesRootAnalyzer
  end
  def updateSubNodesNamesToCardinalities(aSubNodeName)
    aSubNodeCardinality = @subNodesNamesToCardinalities[aSubNodeName]
    @subNodesNamesToCardinalities[aSubNodeName] = aSubNodeCardinality + 1
  end
  def NodeAnalyzer.recordNode(aNodeAnalyzer)
    if aNodeAnalyzer.fullNodePath.empty? == false
      if @@fullPaths.include?(aNodeAnalyzer.fullNodePath) == false then @@fullPaths << aNodeAnalyzer.fullNodePath end
      # record a full path in regard to its xml file (records it only one for a given xlm file)
      someFiles = @@fullPathsToFiles[aNodeAnalyzer.fullNodePath]
      if someFiles == nil 
        someFiles = Array.new(); @@fullPathsToFiles[aNodeAnalyzer.fullNodePath] = someFiles; 
      end
      if !someFiles.include?(aNodeAnalyzer.file) then someFiles << aNodeAnalyzer.file end
    end
    #record cardinalties of sub nodes for a given xml file
    someFilesToSubNodesNamesToCardinalities = @@fullPathToFilesToSubNodesNamesToCardinalities[aNodeAnalyzer.fullNodePath]
    if someFilesToSubNodesNamesToCardinalities == nil 
      someFilesToSubNodesNamesToCardinalities = Hash.new(); @@fullPathToFilesToSubNodesNamesToCardinalities[aNodeAnalyzer.fullNodePath] = someFilesToSubNodesNamesToCardinalities ; 
    end
    someSubNodesNamesToCardinalities = someFilesToSubNodesNamesToCardinalities[aNodeAnalyzer.file]
    if someSubNodesNamesToCardinalities == nil
      someSubNodesNamesToCardinalities = Hash.new(0); someFilesToSubNodesNamesToCardinalities[aNodeAnalyzer.file] = someSubNodesNamesToCardinalities
      someSubNodesNamesToCardinalities.update(aNodeAnalyzer.subNodesNamesToCardinalities)
    else
      aNodeAnalyzer.subNodesNamesToCardinalities.each() do |aSubNodeName, aCardinality|
        someSubNodesNamesToCardinalities[aSubNodeName] = someSubNodesNamesToCardinalities[aSubNodeName] + aCardinality
      end
    end  
    #puts "someSubNodesNamesToCardinalities for #{aNodeAnalyzer.fullNodePath}: #{someSubNodesNamesToCardinalities}"
  end
  def file
    #if @file.empty? then @father.file else return @file end
    if @file.empty? then if @father != nil then return @father.file else return '' end else return @file end
end
def fullNodePath
  if @father == nil then return '' elsif @father.name.empty? then return @name else return @father.fullNodePath+"/"+@name end
end
def to_s
  s = ""
  if @name.empty? == false
    s = "#{@indent}#{self.fullNodePath} [#{self.file}]\n"
  end
  @subNodesAnalyzers.each() do |aSubNodeAnalyzer|
    s = s + aSubNodeAnalyzer.to_s
  end
  return s
end
def NodeAnalyzer.displayStats(aFullPath="")
  s = "";
  if aFullPath.empty? then s = "Statistical Elements Analysis of #{@@nodesRootAnalyzer.subNodesAnalyzers.length} xml documents with #{@@fullPaths.length} elements\n" end
  someFullPaths = @@fullPaths.sort
  someFullPaths.each do |aFullPath|
    s = s + getIndentedNameFromFullPath(aFullPath) + "*"
    nbFilesWithThatFullPath = getNbFilesWithThatFullPath(aFullPath);
    aParentFullPath = getParentFullPath(aFullPath)
    nbFilesWithParentFullPath = getNbFilesWithThatFullPath(aParentFullPath);
    aNameFromFullPath = getNameFromFullPath(aFullPath)
    someFilesToSubNodesNamesToCardinalities = @@fullPathToFilesToSubNodesNamesToCardinalities[aParentFullPath]
    someCardinalities = Array.new()
    someFilesToSubNodesNamesToCardinalities.each() do |aFile, someSubNodesNamesToCardinalities|
      aCardinality = someSubNodesNamesToCardinalities[aNameFromFullPath]
      if aCardinality > 0 && someCardinalities.include?(aCardinality) == false then someCardinalities << aCardinality end
    end
    if someCardinalities.length == 1
      s = s + someCardinalities.to_s + " "
    else
      anAvg = someCardinalities.inject(0) {|sum,value| Float(sum) + Float(value) } / Float(someCardinalities.length)
      s = s + sprintf('%.1f', anAvg) + " " + someCardinalities.min.to_s + "..." + someCardinalities.max.to_s + " "
    end
    s = s + sprintf('%d', Float(nbFilesWithThatFullPath) / Float(nbFilesWithParentFullPath) * 100) + '%'
    s = s + "\n"
  end
  return s
end
def NodeAnalyzer.getNameFromFullPath(aFullPath)
  if aFullPath.include?("/") == false then return aFullPath end
  aNameFromFullPath = aFullPath.dup
  aNameFromFullPath[/^(?:[^\/]+\/)+/] = ""
  return aNameFromFullPath
end
def NodeAnalyzer.getIndentedNameFromFullPath(aFullPath)
  if aFullPath.include?("/") == false then return aFullPath end
  anIndentedNameFromFullPath = aFullPath.dup
#  anIndentedNameFromFullPath = anIndentedNameFromFullPath.gsub(/[^\/]+\//, "  ")
  return anIndentedNameFromFullPath
end
def NodeAnalyzer.getParentFullPath(aFullPath)
  if aFullPath.include?("/") == false then return "" end
  aParentFullPath = aFullPath.dup
  aParentFullPath[/\/[^\/]+$/] = ""
  return aParentFullPath
end
def NodeAnalyzer.getNbFilesWithThatFullPath(aFullPath)
  if aFullPath.empty? 
    return @@nodesRootAnalyzer.subNodesAnalyzers.length
  else
    return @@fullPathsToFiles[aFullPath].length;
  end
end
end
class REXML::Document
  def analyze(node, aFatherNodeAnalyzer, aFile="")
    anNodeAnalyzer = NodeAnalyzer.new(node.name, aFatherNodeAnalyzer, aFile)
    node.elements.each() do |aSubNode| analyze(aSubNode, anNodeAnalyzer) end
    NodeAnalyzer.recordNode(anNodeAnalyzer)
  end
end

begin
  dirpath = ARGV[0]
  Dir.foreach(dirpath) do |anXmlFile|
    if anXmlFile =~ /\.xml/
      anXmlFileContent = File.read("#{dirpath}#{anXmlFile}")
      anXmlDocument = Document.new(anXmlFileContent)
      puts "Analyzing #{anXmlFile}: #{NodeAnalyzer.nodesRootAnalyzer.name}"
      anXmlDocument.analyze(anXmlDocument.root,NodeAnalyzer.nodesRootAnalyzer, anXmlFile.to_s)
    end
  end
  NodeAnalyzer.recordNode(NodeAnalyzer.nodesRootAnalyzer)
  puts NodeAnalyzer.displayStats
end
