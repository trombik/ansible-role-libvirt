require "spec_helper"
require "serverspec"

package = "libvirt"
extra_packages = []
config_dir = "/etc/libvirt"
service = "libvirtd"
default_user = "root"
default_group = "root"
group = "libvirt"
hypervisor = "qemu"

case os[:family]
when "freebsd"
  config_dir = "/usr/local/etc/libvirt"
  extra_packages = ["grub2-bhyve"]
  default_group = "wheel"
  hypervisor = "bhyve"
  group = "wheel"
when "ubuntu"
  extra_packages = ["qemu-kvm"]
  package = "libvirt-bin"
  group = "libvirtd"
when "redhat"
  group = "libvirt"
end

libvirtd_conf = "#{config_dir}/libvirtd.conf"

describe group(group) do
  it { should exist }
end

case os[:family]
when "ubuntu"
  describe file "/etc/default/libvirt-bin" do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { match(/^start_libvirtd="yes"$/) }
    its(:content) { match(/^libvirtd_opts="--config #{libvirtd_conf}"$/) }
  end
when "redhat"
  describe file "/etc/sysconfig/libvirtd" do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^LIBVIRTD_ARGS="--config #{libvirtd_conf}"$/) }
  end
when "freebsd"
  describe file "/etc/rc.conf.d/#{service}" do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(/^libvirtd_flags="--config #{libvirtd_conf}"$/) }
  end
end

describe file config_dir do
  it { should exist }
  it { should be_directory }
end

describe package(package) do
  it { should be_installed }
end

extra_packages.each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe command "virsh --version" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^\d+\.\d+\.\d+$/) }
end

describe file "#{config_dir}/removeme.conf" do
  it { should_not exist }
end

describe file "#{config_dir}/libvirtd.conf" do
  it { should exist }
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by default_user }
  it { should be_grouped_into os[:family] == "redhat" ? "daemon" : "operator" }
  its(:content) { should match(/^log_level = 2$/) }
  its(:content) { should match(/^unix_sock_group = "#{group}"$/) }
  its(:content) { should match(/^unix_sock_ro_perms = "0777"$/) }
  its(:content) { should match(/^unix_sock_rw_perms = "0770"$/) }
  its(:content) { should match(/^auth_unix_ro = "none"$/) }
  its(:content) { should match(/^auth_unix_rw = "none"$/) }
end

describe service(service) do
  it { should be_enabled }
  it { should be_running }
end

describe command "virsh -c #{hypervisor}:///system version" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^Compiled against library: libvirt \d+\.\d+\.\d+$/) }
  its(:stdout) { should match(/^Running hypervisor: #{hypervisor.upcase} \d+\.\d+\.\d+$/) }
end
