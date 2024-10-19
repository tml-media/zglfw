const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const lib = b.addStaticLibrary(.{
        .name = "zglfw",
        .root_source_file = b.path("src/glfw.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibC();

    if (b.lazyDependency("glfw", .{})) |dep| {
        lib.linkLibrary(dep.artifact("glfw"));
    }

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "sample",
        .root_source_file = b.path("src/sample.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibrary(lib);

    _ = b.addModule("glfw", .{ .root_source_file = b.path("src/glfw.zig") });
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
