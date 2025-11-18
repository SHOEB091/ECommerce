const crypto = require('crypto');

const mockState = {
  instances: [],
};

jest.mock('@aws-sdk/client-s3', () => {
  const createSend = () => jest.fn().mockResolvedValue({});

  const S3Client = jest.fn(() => {
    const instance = {
      send: createSend(),
    };
    mockState.instances.push(instance);
    return instance;
  });

  const PutObjectCommand = jest.fn((input) => ({ input }));
  const DeleteObjectCommand = jest.fn((input) => ({ input }));

  return {
    S3Client,
    PutObjectCommand,
    DeleteObjectCommand,
    __mockState: mockState,
  };
});

const getAwsSdkMock = () => require('@aws-sdk/client-s3');

const loadS3Module = () => {
  jest.resetModules();
  return require('../../config/s3');
};

const setBaseEnv = (overrides = {}) => {
  process.env.AWS_S3_BUCKET = overrides.bucket ?? 'test-bucket';
  process.env.AWS_REGION = overrides.region ?? 'ap-south-1';
  process.env.AWS_S3_PUBLIC_BASE_URL = overrides.publicBaseUrl;
  process.env.AWS_ACCESS_KEY_ID = 'AKIA_TEST';
  process.env.AWS_SECRET_ACCESS_KEY = 'SECRET_TEST';
};

describe('S3 config helpers', () => {
  let warnSpy;

  beforeEach(() => {
    warnSpy = jest.spyOn(console, 'warn').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.clearAllMocks();
    delete process.env.AWS_S3_BUCKET;
    delete process.env.AWS_REGION;
    delete process.env.AWS_S3_PUBLIC_BASE_URL;
    delete process.env.AWS_ACCESS_KEY_ID;
    delete process.env.AWS_SECRET_ACCESS_KEY;
    mockState.instances.length = 0;
    warnSpy.mockRestore();
  });

  it('uploads buffer and returns deterministic public URL when config is present', async () => {
    setBaseEnv({ publicBaseUrl: 'https://cdn.example.com' });
    const dateSpy = jest.spyOn(Date, 'now').mockReturnValue(1700000000000);
    const randomSpy = jest.spyOn(crypto, 'randomUUID').mockReturnValue('unit-test-uuid');

    const { uploadBufferToS3 } = loadS3Module();
    const { __mockState, PutObjectCommand } = getAwsSdkMock();
    const buffer = Buffer.from('test image');

    const result = await uploadBufferToS3({
      buffer,
      mimetype: 'image/png',
      folder: 'avatars',
      originalName: 'My Profile Pic.png',
    });

    expect(result).toEqual({
      key: 'avatars/1700000000000-unit-test-uuid.png',
      url: 'https://cdn.example.com/avatars/1700000000000-unit-test-uuid.png',
    });

    const latestInstance = __mockState.instances[__mockState.instances.length - 1];
    expect(latestInstance.send).toHaveBeenCalledTimes(1);
    expect(PutObjectCommand).toHaveBeenCalledWith(
      expect.objectContaining({
        Bucket: 'test-bucket',
        Key: 'avatars/1700000000000-unit-test-uuid.png',
        Body: buffer,
        ContentType: 'image/png',
        ACL: 'public-read',
      }),
    );

    dateSpy.mockRestore();
    randomSpy.mockRestore();
  });

  it('throws a helpful error when bucket is missing', async () => {
    setBaseEnv({ bucket: '' });
    const { uploadBufferToS3 } = loadS3Module();

    await expect(
      uploadBufferToS3({ buffer: Buffer.from('x'), mimetype: 'text/plain' }),
    ).rejects.toThrow('AWS_S3_BUCKET is not configured.');
  });

  it('sends delete command when deleteFromS3 receives a key', async () => {
    setBaseEnv();
    const { deleteFromS3 } = loadS3Module();
    const { __mockState, DeleteObjectCommand } = getAwsSdkMock();

    await deleteFromS3('uploads/test-key.png');

    const latestInstance = __mockState.instances[__mockState.instances.length - 1];
    expect(latestInstance.send).toHaveBeenCalledTimes(1);
    expect(DeleteObjectCommand).toHaveBeenCalledWith(
      expect.objectContaining({
        Bucket: 'test-bucket',
        Key: 'uploads/test-key.png',
      }),
    );
  });
});


