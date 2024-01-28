import { auth, messaging } from "firebase-admin";
import { pubsub } from "firebase-functions";
import { getFCMTokensForUser } from "./common";
import { firebase_dynamic_links_prefix, packageName } from "./environment";

export const sendNewYearMessage = pubsub
  .schedule("0 0 1 1 *")
  .timeZone("Africa/Cairo")
  .onRun(async () => {
    let usersToSend: string[] = [];

    usersToSend = await Promise.all(
      ((await auth().listUsers()).users as any).map(
        async (user: any) => await getFCMTokensForUser(user.uid)
      )
    );
    usersToSend = usersToSend
      .reduce<string[]>((accumulator, value) => accumulator.concat(value), [])
      .filter((v) => v !== null && v !== undefined);

    await messaging().sendToDevice(
      usersToSend,
      {
        notification: {
          title: "أسرة البرنامج تتمنى لكم سنة جديدة سعيدة 🎇",
          body: `أهنئكم ببدايه سنة جديدة. وأحب أن أقول لكم:
نريد أن تكون هذه السنة الجديدة، جديدة فى كل شئ.
جديدة فى الحياة، فى الأسلوب، فى السيرة، فى الطباع...
يشعر فيها كل منا، أن حياته قد تغيرت حقًا إلى أفضل. وكما قال الرسول "الأشياء العتيقة قد مضت. هوذا الكل قد صار جديدًا" (2كو5: 17).
نحن نريد أن نستغل هذا العام الجديد، لنعمل فيه عملًا لأجل الرب، ويعمل الرب فيه عملًا لأجلنا. ونقول فيه: 
كفى يارب علينا السنوات القديمة التى أكلها الجراد.
نريد أن نبدأ معك عهدًا جديدًا وحياه جديدة، نفرح بك وبسكناك فى قلوبنا، وتجدد مثل النسر شبابنا. فيهتف كل منا: إمنحنى بهجه خلاصك... قلبًا نقيًا أخلق فيّ يا الله. وروحًا مستقيمًا جدد فى أحشائى (مز50).

#البابا_شنوده_الثالث`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          type: "Message",
          title: "Happy New Year! 🎉🎇🎆",
          content: `أهنئكم ببدايه سنة جديدة. وأحب أن أقول لكم:
نريد أن تكون هذه السنة الجديدة، جديدة فى كل شئ.
جديدة فى الحياة، فى الأسلوب، فى السيرة، فى الطباع...
يشعر فيها كل منا، أن حياته قد تغيرت حقًا إلى أفضل. وكما قال الرسول "الأشياء العتيقة قد مضت. هوذا الكل قد صار جديدًا" (2كو5: 17).
نحن نريد أن نستغل هذا العام الجديد، لنعمل فيه عملًا لأجل الرب، ويعمل الرب فيه عملًا لأجلنا. ونقول فيه: 
كفى يارب علينا السنوات القديمة التى أكلها الجراد.
نريد أن نبدأ معك عهدًا جديدًا وحياه جديدة، نفرح بك وبسكناك فى قلوبنا، وتجدد مثل النسر شبابنا. فيهتف كل منا: إمنحنى بهجه خلاصك... قلبًا نقيًا أخلق فيّ يا الله. وروحًا مستقيمًا جدد فى أحشائى (مز50).

#البابا_شنوده_الثالث`,
          attachement:
            firebase_dynamic_links_prefix +
            "/viewImage?url=https%3A%2F%2Flh3.googleusercontent.com%2Fpw%2FAL9nZEU1DeEE95ZnzsCRQwa3PomgPxbwwagYlAn3D7tvljE_IEaj6hVlYRLSATrmx3a-cI5ESaGCtn5CI00Q4NprAbAYaT5ujbKyfhM-ZkmJ-vfpiGa3XhGjf1LYp8UNwCMc54Qed3QIsLi0bXkvUxTunjh_%3Ds932-no",
          attachment:
            "https://lh3.googleusercontent.com/pw/AL9nZEU1DeEE95ZnzsCRQwa3PomgPxbwwagYlAn3D7tvljE_IEaj6hVlYRLSATrmx3a-cI5ESaGCtn5CI00Q4NprAbAYaT5ujbKyfhM-ZkmJ-vfpiGa3XhGjf1LYp8UNwCMc54Qed3QIsLi0bXkvUxTunjh_=s932-no",
          time: String(Date.now()),
          sentFrom: "",
        },
      },
      {
        priority: "high",
        timeToLive: 7 * 24 * 60 * 60,
        restrictedPackageName: packageName,
      }
    );
    return "OK";
  });

export const sendMerryChristmasMessage = pubsub
  .schedule("0 0 7 1 *")
  .timeZone("Africa/Cairo")
  .onRun(async () => {
    let usersToSend: string[] = [];

    usersToSend = await Promise.all(
      ((await auth().listUsers()).users as any).map(
        async (user: any) => await getFCMTokensForUser(user.uid)
      )
    );
    usersToSend = usersToSend
      .reduce<string[]>((accumulator, value) => accumulator.concat(value), [])
      .filter((v) => v !== null && v !== undefined);

    await messaging().sendToDevice(
      usersToSend,
      {
        notification: {
          title: "أسرة البرنامج تتمنى لكم عيد ميلاد سعيد 🎅🎄🎉",
          body: `مبارك هو الذي بإرادته جاء إلى أحشاء مريم، وولِد، وأتى إلى حضنها،ونما في القامة.
مبارك هذا الذي بتجسده اشترى لطبيعتنا البشرية حياة!
مبارك هذا الذي ختم نفوسنا وزينها وخطبها لنفسه عروساً!
مبارك هذا الذي جعل جسدنا خيمة بطبيعته غير المنظورة!


مبارك هو ذاك الذي يعجز فمنا عن تسبيحه كما ينبغي، لأن عظمته تفوق قدرة المتكلمين

*مار افرام السرياني*

كل عيد ميلاد و احنا مملوئين بنعمة و فرح و إدراك للحياة الجديدة التي في المسيح❤️🙏`,
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          type: "Message",
          title: "Merry Christmas! 🎅🎄🎉",
          content: `مبارك هو الذي بإرادته جاء إلى أحشاء مريم، وولِد، وأتى إلى حضنها،ونما في القامة.
مبارك هذا الذي بتجسده اشترى لطبيعتنا البشرية حياة!
مبارك هذا الذي ختم نفوسنا وزينها وخطبها لنفسه عروساً!
مبارك هذا الذي جعل جسدنا خيمة بطبيعته غير المنظورة!


مبارك هو ذاك الذي يعجز فمنا عن تسبيحه كما ينبغي، لأن عظمته تفوق قدرة المتكلمين

*مار افرام السرياني*

كل عيد ميلاد و احنا مملوئين بنعمة و فرح و إدراك للحياة الجديدة التي في المسيح❤️🙏`,
          attachement:
            firebase_dynamic_links_prefix +
            "/viewImage?url=https%3A%2F%2Flh3.googleusercontent.com%2Fpw%2FAM-JKLVdRHoLrkCZmk83mp69ynZtVd7ZnpI29Y3k9djvoEi93NSI5olJTr14gH0YUcnE7A4AVK_CkHKk13jNJLDXUOH1m_vIP6UEaJWB3ztwdRnA6-hagTwbTTR2lClv9O094YYg4OBxPxrZnYDea-fBAo4L%3Dw1032-h688-no%3Fauthuser%3D0",
          attachment:
            "https://lh3.googleusercontent.com/pw/AM-JKLVdRHoLrkCZmk83mp69ynZtVd7ZnpI29Y3k9djvoEi93NSI5olJTr14gH0YUcnE7A4AVK_CkHKk13jNJLDXUOH1m_vIP6UEaJWB3ztwdRnA6-hagTwbTTR2lClv9O094YYg4OBxPxrZnYDea-fBAo4L=w1032-h688-no?authuser=0",
          time: String(Date.now()),
          sentFrom: "",
        },
      },
      {
        priority: "high",
        timeToLive: 7 * 24 * 60 * 60,
        restrictedPackageName: packageName,
      }
    );
    return "OK";
  });

export const sendHappyRiseMessage = pubsub
  .schedule("0 0 16 4 *")
  .timeZone("Africa/Cairo")
  .onRun(async () => {
    let usersToSend: string[] = [];

    usersToSend = await Promise.all(
      ((await auth().listUsers()).users as any).map(
        async (user: any) => await getFCMTokensForUser(user.uid)
      )
    );
    usersToSend = usersToSend
      .reduce<string[]>((accumulator, value) => accumulator.concat(value), [])
      .filter((v) => v !== null && v !== undefined);

    await messaging().sendToDevice(
      usersToSend,
      {
        notification: {
          title: "Ⲭⲣⲓⲥⲧⲟⲥ ⲁⲛⲉⲥⲧⲏ... Ⲁⲗⲏⲑⲱⲥ ⲁⲛⲉⲥⲧⲏ",
          body: "المسيح قام... بالحقيقة قام 🎉",
        },
        data: {
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          type: "Message",
          title: "Ⲭⲣⲓⲥⲧⲟⲥ ⲁⲛⲉⲥⲧⲏ... Ⲁⲗⲏⲑⲱⲥ ⲁⲛⲉⲥⲧⲏ 🎉",
          content: "",
          attachement:
            firebase_dynamic_links_prefix +
            "/viewImage?url=https%3A%2F%2Flh3.googleusercontent.com%2Fpw%2FAM-JKLVdRHoLrkCZmk83mp69ynZtVd7ZnpI29Y3k9djvoEi93NSI5olJTr14gH0YUcnE7A4AVK_CkHKk13jNJLDXUOH1m_vIP6UEaJWB3ztwdRnA6-hagTwbTTR2lClv9O094YYg4OBxPxrZnYDea-fBAo4L%3Dw1032-h688-no%3Fauthuser%3D0",
          time: String(Date.now()),
          sentFrom: "",
        },
      },
      {
        priority: "high",
        timeToLive: 7 * 24 * 60 * 60,
        restrictedPackageName: packageName,
      }
    );
    return "OK";
  });
