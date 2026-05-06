import "./global.css";
import { useEffect } from "react";
import { View } from "react-native";
import { StatusBar } from "expo-status-bar";
import {
  SafeAreaProvider,
} from "react-native-safe-area-context";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import * as SplashScreen from "expo-splash-screen";
import {
  useFonts,
  Inter_400Regular,
  Inter_500Medium,
  Inter_600SemiBold,
  Inter_700Bold,
} from "@expo-google-fonts/inter";
import {
  JetBrainsMono_400Regular,
  JetBrainsMono_500Medium,
} from "@expo-google-fonts/jetbrains-mono";
import {
  AppStateProvider,
  useAppState,
  useCurrentJob,
} from "./src/state/AppState";
import { TodayScreen } from "./src/screens/TodayScreen";
import { JobDetailScreen } from "./src/screens/JobDetailScreen";
import { CaptureScreen } from "./src/screens/CaptureScreen";
import { tokens } from "./src/design/tokens";

SplashScreen.preventAutoHideAsync().catch(() => undefined);

function ScreenSwitcher() {
  const { screen, photosByJob } = useAppState();
  const currentJob = useCurrentJob();

  if (screen === "detail" && currentJob) {
    return (
      <JobDetailScreen
        job={currentJob}
        photos={photosByJob[currentJob.id] ?? []}
      />
    );
  }
  if (screen === "capture" && currentJob) {
    return <CaptureScreen job={currentJob} />;
  }
  return <TodayScreen />;
}

export default function App() {
  const [fontsLoaded] = useFonts({
    Inter_400Regular,
    Inter_500Medium,
    Inter_600SemiBold,
    Inter_700Bold,
    JetBrainsMono_400Regular,
    JetBrainsMono_500Medium,
  });

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync().catch(() => undefined);
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return <View style={{ flex: 1, backgroundColor: tokens.colors.cream }} />;
  }

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <AppStateProvider>
          <ScreenSwitcher />
          <StatusBar style="dark" />
        </AppStateProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
