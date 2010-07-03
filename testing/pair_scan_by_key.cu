#include <unittest/unittest.h>
#include <thrust/pair.h>
#include <thrust/transform.h>
#include <thrust/segmented_scan.h>

struct make_pair_functor
{
  template<typename T1, typename T2>
  __host__ __device__
    thrust::pair<T1,T2> operator()(const T1 &x, const T2 &y)
  {
    return thrust::make_pair(x,y);
  } // end operator()()
}; // end make_pair_functor


struct add_pairs
{
  template <typename Pair1, typename Pair2>
  __host__ __device__
    Pair1 operator()(const Pair1 &x, const Pair2 &y)
  {
    return thrust::make_pair(x.first + y.first, x.second + y.second);
  } // end operator()
}; // end add_pairs


template <typename T>
  struct TestPairScanByKey
{
  void operator()(const size_t n)
  {
    typedef thrust::pair<T,T> P;

    thrust::host_vector<T>   h_p1 = unittest::random_integers<T>(n);
    thrust::host_vector<T>   h_p2 = unittest::random_integers<T>(n);
    thrust::host_vector<P>   h_pairs(n);

    // zip up pairs on the host
    thrust::transform(h_p1.begin(), h_p1.end(), h_p2.begin(), h_pairs.begin(), make_pair_functor());

    thrust::device_vector<T> d_p1 = h_p1;
    thrust::device_vector<T> d_p2 = h_p2;
    thrust::device_vector<P> d_pairs = h_pairs;

    thrust::host_vector<T> h_keys(n, 0);
    thrust::device_vector<T> d_keys(n, 0);

    P init = thrust::make_pair(13,13);

    // scan on the host
    thrust::experimental::exclusive_segmented_scan(h_pairs.begin(), h_pairs.end(), h_keys.begin(), h_pairs.begin(), init, add_pairs());

    // scan on the device
    thrust::experimental::exclusive_segmented_scan(d_pairs.begin(), d_pairs.end(), d_keys.begin(), d_pairs.begin(), init, add_pairs());

    ASSERT_EQUAL_QUIET(h_pairs, d_pairs);
  }
};
VariableUnitTest<TestPairScanByKey, IntegralTypes> TestPairScanByKeyInstance;
