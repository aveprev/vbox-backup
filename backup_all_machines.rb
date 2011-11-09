BACKUP_DIR = "/srv/vm/Backup/"

def get_avaliable_machine_ids
  `VBoxManage list vms`.lines.map { |l| l.scan(/\{.*\}/)[0].slice(1..-2) }
end

def generate_snapshot_name
  Time.new.strftime("%Y-%m-%d %H:%M:%S")
end

def take_snapshot(machine_id, snapshot_name)
  `VBoxManage snapshot #{machine_id} take \"#{snapshot_name}\" --pause`
end

def clone_machine(machine_id, snapshot_name)
  `VBoxManage clonevm #{machine_id} --snapshot \"#{snapshot_name}\" --mode machineandchildren --basefolder #{BACKUP_DIR}`
end

def delete_snapshot(machine_id, snapshot_name)
  `VBoxManage snapshot #{machine_id} delete \"#{snapshot_name}\"`
end

def do_backup(machine_ids)
  machine_ids.each do |id|
    snapshot_name = generate_snapshot_name
    take_snapshot(id, snapshot_name)
    clone_machine(id, snapshot_name)
    delete_snapshot(id, snapshot_name)
  end
end

do_backup(get_avaliable_machine_ids)

