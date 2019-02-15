function ref = fn_MFMC_return_object_reference(fname, hdf5_location)

% fid = H5F.create('myfile.h5');
fid = H5F.open(fname)
% type1_id = H5T.copy('H5T_NATIVE_DOUBLE');
% dims = [10 5];
% h5_dims = fliplr(dims);
% h5_maxdims = h5_dims;
% space1_id = H5S.create_simple(2,h5_dims,h5_maxdims);
% dcpl = 'H5P_DEFAULT';
% dset1_id = H5D.create(fid,'my_double',type1_id,space1_id,dcpl);
% type2_id = 'H5T_STD_REF_OBJ';
% space2_id = H5S.create('H5S_SCALAR');
% dset2_id = H5D.create(fid,'my_ref',type2_id,space2_id,dcpl);
ref = H5R.create(fid, hdf5_location, 'H5R_OBJECT', -1);

end