#======================================
# Lamp-Vagrant
# @copyright : Dumday (c) 2017
#======================================
# Command builder
class LinuxCommand
  def initialize
    @commands = []
  end

  ######################
  # Command generators #
  ######################
  # Generate apt-get install
  def install (package_list, params = '-y -qq')
    package_names = package_list.reject(&:empty?).join(" ")
    "apt-get #{params} install #{package_names} 2>/dev/null"
  end

  # Generate apt-get update
  def update (params = '-y -qq')
    "apt-get #{params} update 2>/dev/null"
  end

  # Generate apt-get update
  def clean_up (params = '-y -qq')
    "apt-get #{params} autoremove 2>/dev/null"
  end

  # Restart a service
  def restart_service (service_name)
    "service #{service_name} restart"
  end

  # Generate create file command
  def create_file (file_path)
    "touch '#{file_path}'"
  end

  # Generate copy command
  def copy (source_path, dest_path)
    "cp -arf '#{source_path}' '#{dest_path}'"
  end

  # Generate copy command
  def remove (remove_path)
    "rm -rf '#{remove_path}'"
  end

  # Generate create folder command
  def create_folder (folder_path, params = "-p")
    "mkdir #{params} '#{folder_path}'"
  end

  # Generate a move command
  def move (source_path, dest_path)
    "mv '#{source_path}' '#{dest_path}'"
  end

  # Generate echo command
  def echo (message, params = [])
    sprintf("echo '#{message}'", *params)
  end

  # Generate echo command
  def warning (message, params = [])
    echo("WARNING: #{message}", params)
  end

  # Create command with privileged
  def sudo (command)
    "sudo #{command}"
  end

  # Check if file exists
  def check_file_existence (file_path)
    "[ -f '#{file_path}' ]"
  end

  # Join multiple commands
  def join_commands(params, glue = " && ")
    params.reject(&:empty?).join(glue)
  end

  # Build if statements
  def make_if(if_condtion, if_statement, else_statement = nil, elseif_statements = {})
    commands = []
    commands.push(" if #{if_condtion}; then #{if_statement}; ")

    elseif_statements.each do |condition, statement|
      commands.push(" elif #{condition}; then #{statement}; ")
    end

    if else_statement.to_str.empty?
      commands.push(" fi ")
    else
      commands.push(" else #{else_statement}; fi ")
    end

    commands.join
  end

  ###################
  # Builder methods #
  ###################
  # Get final command
  def get
    to_array.join("\r\n")
  end

  def to_array
    @commands.reject(&:empty?)
  end

  # Alias of get
  def to_str
    get
  end

  # Add a message into queue
  def push_warning (message, params = [])
    push(warning(message, params), false)
  end

  # Add a message into queue
  def push_message (message, params = [])
    push(echo(message, params), false)
  end

  # Add a command into queue
  def push (command, sudo = true)
    if sudo === true
      str_command = "sudo #{command}"
    else
      str_command = "#{command}"
    end

    @commands.push(str_command)
    return str_command
  end

  # Add a file into queue
  def pushFile (file_path)
    if File.file? file_path
      file = File.open(file_path, "rb") # read file contents into string
      @commands.push(file.read)
      file.close # release the file
    end
  end
end
