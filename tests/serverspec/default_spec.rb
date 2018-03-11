require "spec_helper"
require "serverspec"

package = "libvirt"

describe package(package) do
  it { should be_installed }
end
