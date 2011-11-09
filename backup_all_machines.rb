VBOX_MANAGE = "/usr/bin/VBoxManage"
BACKUP_DIR = "/srv/vm/Backup/"

def exec_vbox_manage(*params)
  params.map! { |p| p.include?("\s") ? "\"#{p}\"" : p }
  params_string = params.join "\s"
  exec_string = "#{VBOX_MANAGE} #{params_string}"
  puts "Executing VBoxManage command:\n#{exec_string}"
  `#{exec_string}`
end

def get_available_machine_names
  exec_vbox_manage("list", "vms").lines.map { |l| l.scan(/".*"/)[0].slice(1..-2) }
end

def generate_timestamp_string
  Time.new.strftime("%Y-%m-%d %H:%M:%S")
end

def generate_snapshot_name
  generate_timestamp_string
end

def generate_machine_clone_name(machine_name)
  machine_name + " " + generate_timestamp_string
end

def take_snapshot(machine_name, snapshot_name)
  exec_vbox_manage "snapshot", machine_name, "take", snapshot_name, "--pause"
end

def clone_machine(machine_name, snapshot_name)
  machine_clone_name = generate_machine_clone_name(machine_name)
  exec_vbox_manage "clonevm", machine_name, "--snapshot", snapshot_name, "--name",
      machine_clone_name, "--mode", "machine", "--basefolder", BACKUP_DIR
end

def delete_snapshot(machine_name, snapshot_name)
  exec_vbox_manage "snapshot", machine_name, "delete", snapshot_name
end

def do_backup(machine_names)
  machine_names.each do |name|
    snapshot_name = generate_snapshot_name
    take_snapshot(name, snapshot_name)
    clone_machine(name, snapshot_name)
    delete_snapshot(name, snapshot_name)
  end
end

do_backup(get_available_machine_names)

