#include <unittest/unittest.h>
#include <thrust/uninitialized_copy.h>
#include <thrust/device_malloc_allocator.h>

template <class Vector>
void TestUninitializedCopySimplePOD(void)
{
    typedef typename Vector::value_type T;

    Vector v1(5);
    v1[0] = 0; v1[1] = 1; v1[2] = 2; v1[3] = 3; v1[4] = 4;

    // copy to Vector
    Vector v2(5);
    thrust::uninitialized_copy(v1.begin(), v1.end(), v2.begin());
    ASSERT_EQUAL(v2[0], 0);
    ASSERT_EQUAL(v2[1], 1);
    ASSERT_EQUAL(v2[2], 2);
    ASSERT_EQUAL(v2[3], 3);
    ASSERT_EQUAL(v2[4], 4);
}
DECLARE_VECTOR_UNITTEST(TestUninitializedCopySimplePOD);


template<typename Vector>
void TestUninitializedCopyNSimplePOD(void)
{
    typedef typename Vector::value_type T;

    Vector v1(5);
    v1[0] = 0; v1[1] = 1; v1[2] = 2; v1[3] = 3; v1[4] = 4;

    // copy to Vector
    Vector v2(5);
    thrust::uninitialized_copy_n(v1.begin(), v1.size(), v2.begin());
    ASSERT_EQUAL(v2[0], 0);
    ASSERT_EQUAL(v2[1], 1);
    ASSERT_EQUAL(v2[2], 2);
    ASSERT_EQUAL(v2[3], 3);
    ASSERT_EQUAL(v2[4], 4);
}
DECLARE_VECTOR_UNITTEST(TestUninitializedCopyNSimplePOD);


struct CopyConstructTest
{
  CopyConstructTest(void)
    :copy_constructed_on_host(false),
     copy_constructed_on_device(false)
  {}

  __host__ __device__
  CopyConstructTest(const CopyConstructTest &exemplar)
  {
#if __CUDA_ARCH__
    copy_constructed_on_device = true;
    copy_constructed_on_host   = false;
#else
    copy_constructed_on_device = false;
    copy_constructed_on_device = true;
#endif
  }

  CopyConstructTest &operator=(const CopyConstructTest &x)
  {
    copy_constructed_on_host   = x.copy_constructed_on_host;
    copy_constructed_on_device = x.copy_constructed_on_device;
    return *this;
  }

  bool copy_constructed_on_host;
  bool copy_constructed_on_device;
};


struct TestUninitializedCopyNonPODDevice
{
  void operator()(const size_t dummy)
  {
    typedef CopyConstructTest T;

    thrust::device_vector<T> v1(5), v2(5);

    T x;
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    x = v1[0];
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    thrust::uninitialized_copy(v1.begin(), v1.end(), v2.begin());

    x = v2[0];
    ASSERT_EQUAL(true,  x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);
  }
};
DECLARE_UNITTEST(TestUninitializedCopyNonPODDevice);


struct TestUninitializedCopyNNonPODDevice
{
  void operator()(const size_t dummy)
  {
    typedef CopyConstructTest T;

    thrust::device_vector<T> v1(5), v2(5);

    T x;
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    x = v1[0];
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    thrust::uninitialized_copy_n(v1.begin(), v1.size(), v2.begin());

    x = v2[0];
    ASSERT_EQUAL(true,  x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);
  }
};
DECLARE_UNITTEST(TestUninitializedCopyNNonPODDevice);


struct TestUninitializedCopyNonPODHost
{
  void operator()(const size_t dummy)
  {
    typedef CopyConstructTest T;

    thrust::host_vector<T> v1(5), v2(5);

    T x;
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    x = v1[0];
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    thrust::uninitialized_copy(v1.begin(), v1.end(), v2.begin());

    x = v2[0];
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(true,  x.copy_constructed_on_host);
  }
};
DECLARE_UNITTEST(TestUninitializedCopyNonPODHost);


struct TestUninitializedCopyNNonPODHost
{
  void operator()(const size_t dummy)
  {
    typedef CopyConstructTest T;

    thrust::host_vector<T> v1(5), v2(5);

    T x;
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    x = v1[0];
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(false, x.copy_constructed_on_host);

    thrust::uninitialized_copy_n(v1.begin(), v1.size(), v2.begin());

    x = v2[0];
    ASSERT_EQUAL(false, x.copy_constructed_on_device);
    ASSERT_EQUAL(true,  x.copy_constructed_on_host);
  }
};
DECLARE_UNITTEST(TestUninitializedCopyNNonPODHost);

