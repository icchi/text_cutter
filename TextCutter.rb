# -*- encoding: UTF-8 -*-

#
# カッタークラス
#
class TextCutter

  #
  # 初期化
  #
  def initialize(start_key = "", end_key = "")
    @start_key = start_key
    @end_key = end_key
  end

  #
  # 解析処理
  #
  def analyze(filePath, &block)

    # ファイル全行読み込み
    file_data = File.read(filePath).encode("UTF-8")

    regexp = Regexp.new("#{@start_key}.+?#{@end_key}", Regexp::MULTILINE)
    file_data.scan(regexp) do |data|
      block.call(data)
    end
  end

  attr_accessor :start_key, :end_key

end

@textCutter = TextCutter.new
@files = []

#
# スタートキー設定
#
def startKey(key)
  @textCutter.start_key = key
end

#
# エンドキー設定
#
def endKey(key)
  @textCutter.end_key = key
end

#
# 対象ファイル
#
def target(*files)
  files.each do |file|
    unless File.exist?(file)
      puts "\"#{file}\" is not exist."
      next
    end

    if File::ftype(file) == 'directory'
      # 指定フォルダ内を検索
      Dir.glob(File.expand_path(file + '\*.*')).each do |path|
        @files << path
      end
    else
      @files << file 
    end
  end
end

# 同階層にいるsetting.txtを実行
dir_name = File.dirname(__FILE__)
dsl_data = File.read(dir_name + '\setting.txt', :encoding => Encoding::UTF_8)
dsl_data.scan(/(^startKey.*|^endKey.*|^target.*)/) do |dsl|
  eval(dsl[0])
end

# 結果を出力
File.open(dir_name + '\result.txt', "w") do |outputFile|
  @files.each do |path|
    outputFile.puts(path)
    @textCutter.analyze(path) do |data|
      outputFile.puts(data)
    end
  end
end
