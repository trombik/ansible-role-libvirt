require "spec_helper"
require "serverspec"

package = "libvirt"
extra_packages = []
config_dir = "/etc/libvirt"
service = "libvirtd"
default_user = "root"
default_group = "wheel"

case os[:family]
when "freebsd"
  config_dir = "/usr/local/etc/libvirt"
  extra_packages = ["grub2-bhyve"]
end

case os[:family]
when "freebsd"
  describe file "/etc/rc.conf.d/#{service}" do
    it { should exist }
    it { should be_file }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    it { should be_mode 644 }
    its(:content) { should match(%r{^libvirtd_flags="--config #{config_dir}/libvirtd.conf"$}) }
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
  it { should be_grouped_into "operator" }
  its(:content) { should match(/^log_level = 2$/) }
end

describe service(service) do
  it { should be_enabled }
  it { should be_running }
end

describe command "virt-admin server-list" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^\s*\d+\s+libvirtd\s*$/) }
  its(:stdout) { should match(/^\s*\d+\s+admin\s*$/) }
end
