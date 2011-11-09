BACKUP_DIR = "/srv/vm/Backup/"

def get_available_machine_names
  `VBoxManage list vms`.lines.map { |l| l.scan(/".*"/)[0].slice(1..-2) }
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
  `VBoxManage snapshot \"#{machine_name}\" take \"#{snapshot_name}\" --pause`
end

def clone_machine(machine_name, snapshot_name)
  machine_clone_name = generate_machine_clone_name(machine_name)
  `VBoxManage clonevm \"#{machine_name}\" --snapshot \"#{snapshot_name}\" --name \"#{machine_clone_name}\" --mode machineandchildren --basefolder #{BACKUP_DIR}`
end

def delete_snapshot(machine_name, snapshot_name)
  `VBoxManage snapshot \"#{machine_name}\" delete \"#{snapshot_name}\"`
end

def do_backup(machine_names)
  machine_names.each do |name|
    snapshot_name = generate_snapshot_name
    take_snapshot(name, snapshot_name)
    clone_machine(name, snapshot_name)
    delete_snapshot(name, snapshot_name)
  end
end

do_backup(get_avaliable_machine_names)

