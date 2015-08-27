# This script generates sample for CORDIC testing. 
# It generates a complex integer signal with increasing magnitude and varying phase
import scipy as sp
import numpy as np
from subprocess import call

#def cart2pol(x, y):
#    rho = np.sqrt(x**2 + y**2)
#    phi = np.arctan2(y, x)
#    return(rho, phi)

#def pol2cart(rho, phi):
#    x = rho * np.cos(phi)
#    y = rho * np.sin(phi)
#    return(x, y)

vsim = "/opt/modelsim/modelsim_dlx/bin/vsim"
dofile = "\"run.do\""
make = "/usr/bin/make"

input_filename = "input.samples"
output_filename = "output.samples"

input_bit_width = 16
output_bit_width = 32

#cordic_steps = 16
#cordic_gain = 1
#for i in np.arange(cordic_steps):
#    cordic_gain = cordic_gain*np.sqrt(1+2**(-2*i))

num_samples = int(1e3)

val_max = 2**(input_bit_width-1)-1
val_min = -val_max

adr_i = np.random.random_integers(0, 8, num_samples)
tgd_i = np.linspace(0, num_samples, num_samples)
dat_i = np.random.random_integers(val_min, val_max, num_samples)
# y = np.random.random_integers(val_min, val_max, num_samples)

output = np.transpose([tgd_i, adr_i, dat_i])

np.savetxt(input_filename, output, fmt='%d', delimiter='\t')

make_return = call([make, "-f", "Makefile"])

if make_return != 0:
    raise SystemExit(0)

call([vsim, "-c", "-do","do \"run.do\""])

#(tag_o,adr_o,dat_o) = np.loadtxt(output_filename, dtype = int, unpack = True)

#dat_err = np.empty((num_samples))

#for i in range(len(dat_o)-1):
#    dat_o_0_py, dat_o_1_py = (sinoutput[i][2],output[i][3])
#    mag_py = mag_py/4*cordic_gain #divided by four because of left-side padding in cordic
#    phase_py = phase_py/np.pi*(2**(output_bit_width-1))
#    mag_err[i] = mag[i]   - mag_py
#    phase_err[i] = phase[i] - phase_py

#print("Results:\n")
#print("Magnitude error: max = {0:2.4f}    mean = {2:.4f}    stddev = {1:.4f}".format(np.max(np.absolute(mag_err)),np.std(np.absolute(mag_err)), np.mean(np.absolute(mag_err))))

#print("Phase error:     max = {0:2.4f}    mean = {2:.4f}    stddev = {1:.4f}".format(np.max(np.absolute(phase_err)),np.std(np.absolute(phase_err)), np.mean(np.absolute(phase_err))))

# These functions may be of use for debugging purposes
#print([(i,output[i][:]) for i,mag_err in enumerate(mag_err) if mag_err > 1])
#print([(i,output[i][:]) for i,ph_err in enumerate(phase_err) if ph_err > 1])
