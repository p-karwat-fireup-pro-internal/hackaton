import React from "react";
import { Pressable, Text, View } from "react-native";
import { fontSans, tokens } from "../design/tokens";

export type DemoState = "default" | "offline" | "new" | "empty";

const labels: Record<DemoState, string> = {
  default: "Domyślny",
  offline: "Offline",
  new: "Nowe zlecenie",
  empty: "Wszystko zrobione",
};

const order: DemoState[] = ["default", "offline", "new", "empty"];

export function DemoToggle({
  current,
  onChange,
}: {
  current: DemoState;
  onChange: (s: DemoState) => void;
}) {
  return (
    <View
      style={{
        marginHorizontal: 16,
        marginTop: 8,
        marginBottom: 4,
        padding: 4,
        backgroundColor: tokens.colors["mist-deep"],
        borderRadius: 12,
        flexDirection: "row",
        gap: 2,
      }}
    >
      {order.map((s) => {
        const active = s === current;
        return (
          <Pressable
            key={s}
            onPress={() => onChange(s)}
            style={({ pressed }) => ({
              flex: 1,
              paddingVertical: 8,
              borderRadius: 9,
              backgroundColor: active
                ? tokens.colors.cream
                : pressed
                  ? "rgba(255,255,255,0.4)"
                  : "transparent",
              alignItems: "center",
            })}
          >
            <Text
              style={{
                ...fontSans(active ? 700 : 500),
                color: active ? tokens.colors.title : tokens.colors.muted,
                fontSize: 12,
                letterSpacing: 0.1,
              }}
              numberOfLines={1}
            >
              {labels[s]}
            </Text>
          </Pressable>
        );
      })}
    </View>
  );
}
