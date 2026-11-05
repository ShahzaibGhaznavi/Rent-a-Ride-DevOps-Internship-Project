
import { toast } from "sonner";
import {
  setLatestBooking,
  setisPaymentDone,
} from "../../redux/user/LatestBookingsSlice";
import { setIsSweetAlert, setPageLoading } from "../../redux/user/userSlice";

export function loadScript(src) {
  return new Promise((resolve) => {
    const existingScript = document.querySelector(
      'script[src="https://checkout.razorpay.com/v1/checkout.js"]'
    );

    if (existingScript && window.Razorpay) {
      resolve(true);
      return;
    }

    const script = document.createElement("script");
    script.src = src;
    script.onload = () => resolve(true);
    script.onerror = () => resolve(false);
    document.body.appendChild(script);
  });
}

export const fetchLatestBooking = async (user_id, dispatch) => {
  try {
    const response = await fetch("/api/user/latestbookings", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ user_id }),
    });

    if (!response.ok) {
      throw new Error("Failed to fetch latest booking");
    }

    const data = await response.json();
    dispatch(setLatestBooking(data));
    dispatch(setisPaymentDone(true));

    return data;
  } catch (error) {
    console.error("Error fetching latest booking:", error);
    return null;
  }
};

export async function displayRazorpay(values, navigate, dispatch) {
  try {
    const res = await loadScript(
      "https://checkout.razorpay.com/v1/checkout.js"
    );

    if (!res || !window.Razorpay) {
      throw new Error("Razorpay SDK failed to load. Check your internet connection.");
    }

    const refreshToken = localStorage.getItem("refreshToken");
    const accessToken = localStorage.getItem("accessToken");

    const result = await fetch("/api/user/razorpay", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${refreshToken},${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(values),
    });

    const data = await result.json();

    if (!result.ok || !data.ok) {
      throw new Error(data?.message || "Unable to create payment order");
    }

    const { amount, id, currency } = data;

    const options = {
      key: import.meta.env.VITE_RAZORPAY_KEY_ID,
      amount: amount.toString(),
      currency,
      name: "Rent a Ride",
      description: "Test Transaction",
      order_id: id,

      handler: async function (response) {
        try {
          const paymentData = {
            razorpayPaymentId: response.razorpay_payment_id,
            razorpayOrderId: response.razorpay_order_id,
            razorpaySignature: response.razorpay_signature,
          };

          const dbData = { ...values, ...paymentData };

          const bookingResponse = await fetch("/api/user/bookCar", {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
            },
            body: JSON.stringify(dbData),
          });

          const successStatus = await bookingResponse.json();

          if (!bookingResponse.ok || !successStatus) {
            throw new Error("Booking could not be saved");
          }

          dispatch(setIsSweetAlert(true));

          await fetchLatestBooking(values.user_id, dispatch);

          navigate("/");
        } catch (error) {
          console.error("Booking Error:", error);
          toast.error(error.message || "Booking failed");
        } finally {
          dispatch(setPageLoading(false));
        }
      },

      prefill: {
        name: "Jeevan aj",
        email: "ambrahamjeevan@gmail.com",
        contact: "8086240993",
      },

      theme: {
        color: "#61dafb",
      },

      modal: {
        ondismiss: function () {
          dispatch(setPageLoading(false));
        },
      },
    };

    const paymentObject = new window.Razorpay(options);

    paymentObject.on("payment.failed", function (response) {
      toast.error(
        response.error?.description || "Payment failed. Please try again."
      );
      dispatch(setPageLoading(false));
    });

    paymentObject.open();

    return { ok: true };
  } catch (error) {
    console.error("Razorpay Error:", error);
    toast.error(error.message || "Payment initialization failed");

    return {
      ok: false,
      message: error.message,
    };
  } finally {
    dispatch(setPageLoading(false));
  }
}

const Razorpay = () => {
  return <div></div>;
};

export default Razorpay;
